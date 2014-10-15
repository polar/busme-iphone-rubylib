require "spec_helper"
require "test_platform_api"

describe Platform::Guts do

  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:updateWithRoutes) {
    fileName = File.join("spec", "test_data", "SUUpdateWithRoutes.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:api) {
    api = TestPlatformApi.new
  }
  let (:api2) {
    api = TestPlatformApi.new
  }
  let (:guts) {
    Platform::Guts.new(api)
  }
  let (:guts2) {
    guts1 = Platform::Guts.new(api2)
    guts1.reinitializeAPI(api: api2, directory: "/tmp")
    api2.mock_answer = suGet
    guts1.getMasterApi
    api2.mock_answer = updateWithRoutes
    guts1.api.bgEvents.postEvent("JourneySync", Platform::JourneySyncEventData.new(true))
    guts1.api.bgEvents.roll
    guts1.storeApi
    guts1
  }
  before {
    Dir.glob("/tmp/syracuse-university*.xml").each do |file|
      File.delete(file)
    end
  }

  it "should be able to get a new Master" do
    guts.reinitializeAPI(api: api, directory: "/tmp")
    api.mock_answer = suGet
    guts.getMasterApi
    expect(guts.api.buspass.slug).to eq "syracuse-university"
  end

  it "after reinitialization should be able to get routes" do
    guts.reinitializeAPI(api: api, directory: "/tmp")
    api.mock_answer = suGet
    guts.getMasterApi
    api.mock_answer = updateWithRoutes
    guts.api.bgEvents.postEvent("JourneySync", Platform::JourneySyncEventData.new(true))
    guts.api.bgEvents.roll
    expect(guts.journeyStore.getPattern("b2d03c4880f6d57b3b4edfa5aa9c9211")).to_not eq(nil)
  end

  it "should store routes" do
    expect(!File.exists?("/tmp/syracuse-university-journeys.xml"))
    guts2.storeApi
    expect(File.exists?("/tmp/syracuse-university-journeys.xml"))
  end

  it "after reinitialization should be able to get and save routes" do
    guts2.storeApi

    guts.reinitializeAPI(api: api, directory: "/tmp")
    api.mock_answer = suGet
    guts.getMasterApi
    expect(guts.journeyStore.getPattern("b2d03c4880f6d57b3b4edfa5aa9c9211")).to_not eq(nil)
  end
end