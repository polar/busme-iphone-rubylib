require "spec_helper"

describe Api::DiscoverAPIVersion1 do

  it "should get a response" do
    url = "https://busme-apis.herokuapp.com/apis/d1/get"
    d1 = Api::DiscoverAPIVersion1.new(url)
    expect(d1.get).to be(true)
  end

  it "should be able to find several" do
    url = "https://busme-apis.herokuapp.com/apis/d1/get"
    d1 = Api::DiscoverAPIVersion1.new(url)
    expect(d1.get).to be(true)
    masters = d1.discover(-76.13, 43.04, 1000)
    expect(masters).not_to be_empty
    expect(masters.map {|x| x.slug}).to include("syracuse-university")
  end

  it "should be able to find one" do
    url = "https://busme-apis.herokuapp.com/apis/d1/get"
    d1 = Api::DiscoverAPIVersion1.new(url)
    expect(d1.get).to be(true)
    master = d1.find_master("syracuse-university")
    expect(master).not_to be(nil)
    expect(master.slug).to eq("syracuse-university")
  end
end