require "spec_helper"
require "test_http_client"
require 'test_foreground'

describe Platform::MainController do
  let(:defaultMaster) {
    master = Api::Master.new
    master.name = "Lake Shore Limited Amtrak"
    master.slug = "lake-shore-limited-amtrak"
    master.lon = "-77.317205"
    master.lat = "41.612683"
    master.bbox = [-87.639359,43.20031,-73.738298,40.75041]
    master.apiUrl = "http://busme-apis.herokuapp.com/masters/512e7ea39f9501000e0000d0/apis/1/get"
    master.title = "Lake Shore Limited Amtrak"
    master.description = "The Amtrak Train between New York and Chicago"
    master
  }
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
    TestForeground.new(mainController, ["Main:Init:return", "Main:Discover:Init:return", "Main:Master:Init:return", "Search:Find:return"])
  }
  let (:testMasterForeground) {
    TestForeground.new(mainController.masterController.api, ["Master:Init:return"])
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
    expect(event.eventData.return.first).to be_a_kind_of(Platform::MasterController)
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
    # Instantiated testMasterForground
    testMasterForeground
    httpClient.mock_answer = suGet
    mainController.masterController.api.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    mainController.masterController.api.bgEvents.roll
    api = mainController.masterController.api
    expect(api.ready).to be(true)
    # Since the version is nothing, we should get an upgrade message
    expect(api.buspass.initialMessages).to_not be(nil)
    expect(api.buspass.initialMessages[0].title).to match(/Update/)
    expect(api.buspass.initialMessages[0].content).to match(/You have the 0.0.0/)
    event = mainController.masterController.api.uiEvents.peek
    expect(event.eventName).to eq("Master:Init:return")
    mainController.masterController.api.uiEvents.roll
    expect(testMasterForeground.lastEvent.eventData.return).to be_a(Api::BuspassAPI)
  end

  it "should get a discover for initial start" do
    mainController.bgEvents.postEvent("Main:init", Platform::MainEventData.new(data:{}))
    mainController.bgEvents.roll
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Main:Init:return")
    expect(event.eventData).to_not be nil
    expect(event.eventData.return).to eq("discover")
  end

  it "should get a discover with LastLocation for initial start" do
    lastLocation = Integration::GeoPoint.new(43.0, -76.0)
    mainController.busmeConfigurator.setLastLocation(lastLocation)
    mainController.bgEvents.postEvent("Main:init", Platform::MainEventData.new(data:{}))
    mainController.bgEvents.roll
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Main:Init:return")
    expect(event.eventData).to_not be nil
    expect(event.eventData.return).to eq("discover")
    expect(event.eventData.data[:lastLocation]).to_not eq(nil)
    loc = event.eventData.data[:lastLocation]
    expect Platform::GeoCalc.equalCoordinates(loc, lastLocation)
  end

  it "should get a master for initial start" do
    mainController.busmeConfigurator.setDefaultMaster(defaultMaster)
    mainController.bgEvents.postEvent("Main:init", Platform::MainEventData.new(data:{}))
    mainController.bgEvents.roll
    event = mainController.uiEvents.peek
    expect(event.eventName).to eq("Main:Init:return")
    expect(event.eventData).to_not be nil
    expect(event.eventData.return).to eq("defaultMaster")
    expect(event.eventData.data[:master].apiUrl).to eq(defaultMaster.apiUrl)
    expect(event.eventData.data[:master].slug).to eq(defaultMaster.slug)
    expect(event.eventData.data[:master].title).to eq(defaultMaster.title)
  end
end