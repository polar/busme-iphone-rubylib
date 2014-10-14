require "spec_helper"
require "test_http_client"

class TestForegroundController < Platform::FGBusmeLocatorController
  attr_accessor :eventData
  attr_accessor :method
  def onDiscover(eventData)
    self.eventData = eventData
    self.method = "onDiscover"
  end
  def onGet(eventData)
    self.eventData = eventData
    self.method = "onGet"
  end
end

describe Platform::FGBusmeLocatorController do
  let(:httpClient) {
    Testlib::MyHttpClient.new(TestHttpClient.new)
  }
  let(:api) {
    Api::DiscoverAPIVersion1.new(httpClient, "http://apis.busme.us/apis/d1/get")
  }
  let(:controller) {
    Platform::BusmeLocatorController.new(api)
  }
  let (:discoverGet) {
    fileName = File.join("spec", "test_data", "CNYDiscoverGet.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:discoverMasters) {
    fileName = File.join("spec", "test_data", "CNYDiscover.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:foregroundController) {
    TestForegroundController.new(api)
  }
  before {
    controller
    foregroundController
  }

  it "on get should ping the foreground controller and get an response" do
    httpClient.mock_answer = discoverGet
    foregroundController.performGet("testGet", -73.0, 43.0, 2333)
    api.bgEvents.roll
    expect(api.discoverUrl).to_not be nil
    api.uiEvents.roll
    expect(foregroundController.eventData.get).to_not be nil
    expect(foregroundController.eventData.uiData).to eq "testGet"
    expect(foregroundController.method).to eq "onGet"
  end

  it "on discover should ping the foreground controller and get an response" do
    httpClient.mock_answer = discoverGet
    foregroundController.performGet("testGet", -73.0, 43.0, 2333)
    api.bgEvents.roll
    api.uiEvents.roll
    foregroundController.performDiscover("testDiscover", -73.0, 43.0, 2333)
    api.bgEvents.roll
    api.uiEvents.roll
    expect(foregroundController.eventData.masters).to_not be nil
    expect(foregroundController.eventData.uiData).to eq "testDiscover"
    expect(foregroundController.method).to eq "onDiscover"
  end



end