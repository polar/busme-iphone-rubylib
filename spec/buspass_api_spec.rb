require "spec_helper"

describe Api::BuspassAPI, "API" do
  it "should initialize" do
    url = "https://busme-apis.herokuapp.com/masters/521679a96eec8b000800710b/apis/1/get"
    platform = "Android"
    version = "0.0.0"
    api = Api::BuspassAPI.new(Testlib::MyHttpClient.new, url, platform, version)
    api.get
    expect(api.ready).to be(true)
    # Since the version is nothing, we should get an upgrade message
    expect(api.buspass.initialMessages).to_not be(nil)
    expect(api.buspass.initialMessages[0].title).to match(/Update/)
    expect(api.buspass.initialMessages[0].content).to match(/You have the 0.0.0/)
  end
end