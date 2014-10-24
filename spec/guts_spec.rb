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
    Platform::Guts.new(api: api)
  }
  let (:guts2) {
    guts1 = Platform::Guts.new(api: api2)
    guts1.reinitializeAPI(api: api2, directory: "/tmp")
    api2.mock_answer = suGet
    guts1.getMasterApi
    api2.mock_answer = updateWithRoutes
    guts1.api.bgEvents.postEvent("JourneySync", Platform::JourneySyncEventData.new(isForce: true))
    guts1.api.bgEvents.roll
    guts1.storeMasterApi
    guts1
  }
  let (:guts3) {
    guts1 = Platform::Guts.new(api: api2)
    guts1.reinitializeAPI(api: api2, directory: "/tmp")
    api2.mock_answer = suGet
    guts1.getMasterApi
    api2.mock_answer = updateWithRoutes
    guts1.api.bgEvents.postEvent("JourneySync", Platform::JourneySyncEventData.new(isForce: true))
    guts1.api.bgEvents.roll
    guts1.externalStorageController = Platform::XMLExternalStorageController.new(api: api2, directory: "/tmp")
    guts1.storageSerializerController = Platform::StorageSerializerController.new(api2,guts1.externalStorageController)
    guts1.storeMasterApi
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
    guts.api.bgEvents.postEvent("JourneySync", Platform::JourneySyncEventData.new(isForced: true))
    guts.api.bgEvents.roll
    expect(guts.journeyStore.getPattern("b2d03c4880f6d57b3b4edfa5aa9c9211")).to_not eq(nil)
  end

  it "should store routes" do
    expect(!File.exists?("/tmp/syracuse-university-journeys.xml"))
    guts2.storeMasterApi
    expect(File.exists?("/tmp/syracuse-university-journeys.xml"))
  end

  it "should xml store routes" do
    expect(!File.exists?("/tmp/syracuse-university-journeys.xml"))
    guts3.storeMasterApi
    expect(File.exists?("/tmp/syracuse-university-journeys.xml"))
  end

  it "after reinitialization should be able to get and save routes" do
    guts2.storeMasterApi

    guts.reinitializeAPI(api: api, directory: "/tmp")
    api.mock_answer = suGet
    guts.getMasterApi
    expect(guts.journeyStore.getPattern("b2d03c4880f6d57b3b4edfa5aa9c9211")).to_not eq(nil)
  end

  it "after reinitialization xml should be able to get and save routes" do
    guts3
    guts3.storeMasterApi

    guts3.reinitializeAPI(api: api, directory: "/tmp")
    guts3.externalStorageController = Platform::XMLExternalStorageController.new(api: guts3.api, directory: "/tmp")
    guts3.storageSerializerController = Platform::StorageSerializerController.new(guts3.api,guts3.externalStorageController)
    api.mock_answer = suGet
    guts3.getMasterApi
    expect(guts3.journeyStore.getPattern("b2d03c4880f6d57b3b4edfa5aa9c9211")).to_not eq(nil)
  end
end