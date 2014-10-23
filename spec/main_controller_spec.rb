require "spec_helper"
require "test_http_client"
require 'test_foreground'

describe Platform::MainController do
  let(:httpClient) {
    Testlib::MyHttpClient.new(TestHttpClient.new)
  }
  let(:discoverApi) {
    Api::DiscoverAPIVersion1.new(httpClient, "http://apis.busme.us/apis/d1/get")
  }
  let(:masterApi) {
    Api::BuspassAPI.new(httpClient, "syracuse-university", "http://nothing", "Platform", "0.0.0")
  }
  let(:mainController) {
    Platform::MainController.new
  }
  let (:testForeground) {
    # We list only the events that we care about in this spec
    TestForeground.new(mainController, ["Main:Discover:Init:return", "Main:Master:Init:return", "Master:Init:return", "Search:Find:return"])
  }
  let (:discoverGet) {
    fileName = File.join("spec", "test_data", "CNYDiscoverGet.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:discoverMasters) {
    fileName = File.join("spec", "test_data", "CNYDiscover.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  before {
    mainController
    testForeground
  }

  it "should initialize discover" do
    mainController.bgEvents.postEvent("Main:Discover:init", Platform::MainEventData.new(data:{discoverApi: discoverApi}))
    mainController.bgEvents.roll
    expect(mainController.discoverController).to_not eq(nil)
    expect(mainController.discoverController).to be_a_kind_of(Platform::DiscoverController)
  end

  it "should initialize master" do
    mainController.bgEvents.postEvent("Main:Master:init", Platform::MainEventData.new(data:{masterApi: masterApi}))
    mainController.bgEvents.roll
    expect(mainController.masterController).to_not eq(nil)
    expect(mainController.masterController).to be_a_kind_of(Platform::MasterController)
  end

  it "should on discover fire UI EVent" do
    mainController.bgEvents.postEvent("Main:Discover:init", Platform::MainEventData.new(data:{discoverApi: discoverApi}))
    mainController.bgEvents.roll
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Main:Discover:Init:return")
    expect(event.eventData).to_not be nil
    mainController.uiEvents.roll
    event = testForeground.lastEvent
    expect(event).to_not eq(nil)
    expect(event.eventData.return).to be_a_kind_of(Platform::DiscoverController)
  end

  it "should on master fire UI EVent" do
    mainController.bgEvents.postEvent("Main:Master:init", Platform::MainEventData.new(data:{masterApi: masterApi}))
    mainController.bgEvents.roll
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Main:Master:Init:return")
    expect(event.eventData).to_not be nil
    mainController.uiEvents.roll
    event = testForeground.lastEvent
    expect(event).to_not eq(nil)
    expect(event.eventData.return).to be_a_kind_of(Platform::MasterController)
  end

  it "should select master from discover" do
    mainController.bgEvents.postEvent("Main:Discover:init", Platform::MainEventData.new(data:{discoverApi: discoverApi}))
    mainController.bgEvents.roll
    mainController.uiEvents.roll
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
    #masterApi = Api::BuspassAPI.new(httpClient, master.slug, master.apiUrl, "TestPlatform", "0.0.0")
    mainController.bgEvents.postEvent("Search:select",
                                      Platform::DiscoverEventData.new(data:{master: master, masterApi: masterApi}))
    mainController.bgEvents.roll
    expect(mainController.masterController).to_not be(nil)
    expect(mainController.masterController).to be_a_kind_of(Platform::MasterController)
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Search:Select:return")
    mainController.uiEvents.roll
    expect(mainController.masterController).to_not eq(nil)
    expect(mainController.masterController.master).to_not eq(nil)
    expect(mainController.masterController.master).to be_a_kind_of(Api::Master)
    expect(mainController.masterController.master.slug).to eq("syracuse-university")
    httpClient.mock_answer = suGet
    mainController.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    mainController.bgEvents.roll
    api = mainController.masterController.api
    expect(api.ready).to be(true)
    # Since the version is nothing, we should get an upgrade message
    expect(api.buspass.initialMessages).to_not be(nil)
    expect(api.buspass.initialMessages[0].title).to match(/Update/)
    expect(api.buspass.initialMessages[0].content).to match(/You have the 0.0.0/)
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Master:Init:return")
    mainController.uiEvents.roll
    expect(testForeground.lastEvent.eventData.return).to eq(true)
  end
end