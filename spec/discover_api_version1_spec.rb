require "spec_helper"
require "test_http_client"

describe Api::DiscoverAPIVersion1 do
  let (:discoverGet) {
    fileName = File.join("spec", "test_data", "CNYDiscoverGet.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:cnyDiscoverSU) {
    fileName = File.join("spec", "test_data", "CNYDiscoverSU.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:httpClient) {
    TestHttpClient.new
  }
  let (:api) {
    d1 = Api::DiscoverAPIVersion1.new(Testlib::MyHttpClient.new(httpClient), "https://something/apis/d1/get")
    httpClient.mock_answer = discoverGet
    d1
  }

  it "should get a response" do
    url = "https://busme-apis.herokuapp.com/apis/d1/get"
    d1 = Api::DiscoverAPIVersion1.new(Testlib::MyHttpClient.new, url)
    expect(d1.get).to be(true)
  end

  it "should be able to find several" do
    url = "https://busme-apis.herokuapp.com/apis/d1/get"
    d1 = Api::DiscoverAPIVersion1.new(Testlib::MyHttpClient.new, url)
    expect(d1.get).to be(true)
    masters = d1.discover(-76.13, 43.04, 1000)
    expect(masters).not_to be_empty
    expect(masters.map {|x| x.slug}).to include("syracuse-university")
  end

  it "should be able to find one" do
    url = "https://busme-apis.herokuapp.com/apis/d1/get"
    d1 = Api::DiscoverAPIVersion1.new(Testlib::MyHttpClient.new, url)
    expect(d1.get).to be(true)
    master = d1.find_master("syracuse-university")
    expect(master).not_to be(nil)
    expect(master.slug).to eq("syracuse-university")
  end

  it "should be able to parse a master" do
    expect(api.get).to be(true)
    httpClient.mock_answer = cnyDiscoverSU
    master = api.find_master("syracuse-university")
    expect(master).not_to be(nil)
    expect(master.slug).to eq("syracuse-university")
    expect(master.bbox.length).to eq(4)
  end
end