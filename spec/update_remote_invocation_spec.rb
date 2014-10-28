require "spec_helper"
require "test_platform_api"

describe Platform::UpdateRemoteInvocation do
  let (:time_now) {Time.now}
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:badResponse) { TestHttpMessage.new(500, "Internal Error", "")}

  let (:api) {
    api = TestPlatformApi.new
    api.mock_answer = suGet
    api
  }
  let (:guts) { Platform::Guts.new(api: api) }
  let (:response) {
    fileName = File.join("spec", "test_data", "SUUpdate.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:syncresponse) {
    fileName = File.join("spec", "test_data", "SUUpdateWithRoutes.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let(:mainController) {
    Platform::MainController.new(api: api, directory: "/tmp")
  }
  let(:masterController) {
    Platform::MasterController.new(api: api, mainController: mainController)
  }
  before do
    api.mock_answer = suGet
    masterController.api.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    masterController.api.bgEvents.roll
    expect(api.ready).to be(true)
  end

  it "should process response, getting banners, markers, and messages, and update rates" do
    # From the SUGet.xml
    expect(api.updateRate.to_i).to eq(60000)
    expect(api.syncRate.to_i).to eq(60000)
    guts.api.mock_answer = response
    guts.updateRemoteInvocation.invoke(nil, nil)
    # From the SUUpdate.xml
    expect(guts.bannerBasket.getBanners.map {|x| x.id}).to include("1")
    expect(guts.markerBasket.getMarkers.map {|x| x.id}).to include("1")
    expect(guts.masterMessageBasket.getMasterMessages.map {|x| x.id}).to include("1")
    # Make sure rates get updated
    expect(api.updateRate).to eq(30000)
    expect(api.syncRate).to eq(100000)
  end

  it "should via buspass event, process response, getting banners, markers, and messages, and update rates" do
    # From the SUGet.xml
    expect(api.updateRate.to_i).to eq(60000)
    expect(api.syncRate.to_i).to eq(60000)
    masterController.api.mock_answer = response

    masterController.api.bgEvents.postEvent("Update", Platform::UpdateEventData.new)
    masterController.api.bgEvents.roll

    # From the SUUpdate.xml
    expect(masterController.bannerBasket.getBanners.map {|x| x.id}).to include("1")
    expect(masterController.markerBasket.getMarkers.map {|x| x.id}).to include("1")
    expect(masterController.masterMessageBasket.getMasterMessages.map {|x| x.id}).to include("1")
    # Make sure rates get updated
    expect(masterController.api.updateRate).to eq(30000)
    expect(masterController.api.syncRate).to eq(100000)
  end

  it "should save location" do
    masterController.api.mock_answer = syncresponse

    masterController.api.bgEvents.postEvent("JourneySync", Platform::UpdateEventData.new)
    masterController.api.bgEvents.roll
    jd = masterController.journeyDisplayController.journeyDisplayMap["968f501b3e02890cffa2a1e1b80bc3ca"]
    expect(jd).to_not eq(nil)

    # Do all UI events
    while masterController.api.uiEvents.roll

    end
    masterController.api.mock_answer = response

    masterController.api.bgEvents.postEvent("Update", Platform::UpdateEventData.new)
    masterController.api.bgEvents.roll
    jd = masterController.journeyDisplayController.journeyDisplayMap["968f501b3e02890cffa2a1e1b80bc3ca"]
    expect(jd).to_not eq(nil)
    expect(jd.route.lastKnownLocation).to_not eq(nil)
    expect(jd.route.lastKnownLocation.latitude).to eq(43.074535)
    expect(jd.route.lastKnownLocation.longitude).to eq(-76.170796)
  end

end

