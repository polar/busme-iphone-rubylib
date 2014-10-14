require "spec_helper"
require "test_http_client"
require 'test_foreground'

describe Platform::BusmeLocatorController do
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
  let (:testForeground) {
    TestForeground.new(api, ["Locator:onGet", "Locator:onDiscover"])
  }
  before {
    controller
    testForeground
  }
  it "should get the right urls" do
    httpClient.mock_answer = discoverGet
    api.bgEvents.postEvent("Locator:get", Platform::LocatorGetEventData.new(nil, -73, 43, 10000, nil))
    api.bgEvents.roll
    expect(api.discoverUrl).to_not be nil
    expect(api.masterUrl).to_not be nil
  end

  it "should get the fire UI EVent" do
    httpClient.mock_answer = discoverGet
    api.bgEvents.postEvent("Locator:get", Platform::LocatorGetEventData.new(nil, -73, 43, 10000, nil))
    api.bgEvents.roll
    event = api.uiEvents.peek
    expect(event.eventData).to_not be nil
    api.uiEvents.roll
    expect(testForeground.lastEvent.eventData.get).to_not be nil
  end

  it "should get a response for discover" do
    httpClient.mock_answer = discoverGet
    api.bgEvents.postEvent("Locator:get", Platform::LocatorGetEventData.new(nil, -73, 43, 10000, nil))
    api.bgEvents.roll
    # Ui Event should just disappear
    api.uiEvents.roll

    httpClient.mock_answer = discoverMasters
    api.bgEvents.postEvent("Locator:discover", Platform::LocatorDiscoverEventData.new(nil, -73, 43, 10000, nil))
    api.bgEvents.roll
    api.uiEvents.roll
    expect(testForeground.lastEvent.eventData.masters).to_not be nil
  end
end