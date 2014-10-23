require "spec_helper"
require "test_http_client"
require 'test_foreground'

class TestMainController < Platform::MainController
  attr_accessor :switched
  attr_accessor :switched_master
  def switchMaster(master, api)
    self.switched = api
    self.switched_master = master
    super(master, api)
  end
end


describe Platform::DiscoverController do
  let(:httpClient) {
    Testlib::MyHttpClient.new(TestHttpClient.new)
  }
  let(:api) {
    Api::DiscoverAPIVersion1.new(httpClient, "http://apis.busme.us/apis/d1/get")
  }
  let(:mainController) {
    TestMainController.new
  }
  let(:discoverController) {
    Platform::DiscoverController.new(api: api, mainController: mainController)
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
    TestForeground.new(mainController, ["Search:Init:return", "Search:Discover:return", "Search:Find:return", "Search:Select:return"])
  }
  before {
    mainController
    discoverController
    testForeground
  }
  it "should get the right urls" do
    httpClient.mock_answer = discoverGet
    mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new())
    mainController.bgEvents.roll
    expect(api.discoverUrl).to_not be nil
    expect(api.masterUrl).to_not be nil
  end

  it "should get the fire UI EVent" do
    httpClient.mock_answer = discoverGet
    mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new())
    mainController.bgEvents.roll
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Search:Init:return")
    expect(event.eventData).to_not be nil
    mainController.uiEvents.roll
    event = testForeground.lastEvent
    expect(event).to_not eq(nil)
    expect(event.eventData).to be_a_kind_of(Platform::DiscoverEventData)
    expect(event.eventData.return).to eq(true)
  end

  it "should get a response for discover" do
    httpClient.mock_answer = discoverGet
    mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new())
    mainController.bgEvents.roll
    # Ui Event should just disappear
    mainController.uiEvents.roll
    # clears lastEvent
    expect(testForeground.lastEvent.eventData.return).to_not be nil

    httpClient.mock_answer = discoverMasters
    mainController.bgEvents.postEvent("Search:discover", Platform::DiscoverEventData.new(data:{lat:-73,lon: 43, buf:10000}))
    mainController.bgEvents.roll
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Search:Discover:return")
    mainController.uiEvents.roll
    evd = testForeground.lastEvent.eventData
    expect(evd.return).to_not be nil
    expect(evd.return).to be_a_kind_of Array
    expect(evd.return[0]).to be_a_kind_of Api::Master
  end

  it "should find master from discover" do
    httpClient.mock_answer = discoverGet
    mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new())
    mainController.bgEvents.roll
    # Ui Event should just disappear
    mainController.uiEvents.roll
    # clears lastEvent
    expect(testForeground.lastEvent.eventData.return).to_not be nil

    httpClient.mock_answer = discoverMasters
    mainController.bgEvents.postEvent("Search:discover", Platform::DiscoverEventData.new(data:{lat:-73,lon: 43, buf:10000}))
    mainController.bgEvents.roll
    mainController.uiEvents.roll
    #clears lastEvent
    expect(testForeground.lastEvent.eventData.return).to_not be nil

    gp = Integration::GeoPoint.new(43.0E6, -76.1E6)
    mainController.bgEvents.postEvent("Search:find", Platform::DiscoverEventData.new(data:{loc: gp}))
    mainController.bgEvents.roll
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Search:Find:return")
    mainController.uiEvents.roll
    expect(testForeground.lastEvent.eventData.return).to_not be nil

  end

  it "should select master from discover" do
    httpClient.mock_answer = discoverGet
    mainController.bgEvents.postEvent("Search:init", Platform::DiscoverEventData.new())
    mainController.bgEvents.roll
    mainController.uiEvents.roll
    httpClient.mock_answer = discoverMasters
    mainController.bgEvents.postEvent("Search:discover", Platform::DiscoverEventData.new(data:{lat:-73,lon: 43, buf:10000}))
    mainController.bgEvents.roll
    mainController.uiEvents.roll
    gp = Integration::GeoPoint.new(43.0E6, -76.1E6)
    mainController.bgEvents.postEvent("Search:find", Platform::DiscoverEventData.new(data:{loc: gp}))
    mainController.bgEvents.roll
    mainController.uiEvents.roll
    master = testForeground.lastEvent.eventData.return
    expect(master).to_not eq(nil)
    masterApi = Api::BuspassAPI.new(httpClient, master.slug, master.apiUrl, "TestPlatform", "0.0.0")
    mainController.bgEvents.postEvent("Search:select",
                        Platform::DiscoverEventData.new(data:{master: master, masterApi: masterApi}))
    mainController.bgEvents.roll
    expect(mainController.switched).to_not eq(nil)
    expect(mainController.switched).to be_a_kind_of(Api::BuspassAPI)
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Search:Select:return")
    mainController.uiEvents.roll
  end
end