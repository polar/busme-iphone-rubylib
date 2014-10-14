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
    api.forceGet
    api
  }
  let (:guts) { Platform::Guts.new(api) }
  let (:response) {
    fileName = File.join("spec", "test_data", "SUUpdate.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  before do
    api
    guts
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
    guts.api.mock_answer = response

    guts.api.bgEvents.postEvent("Update", Platform::UpdateEventData.new)
    guts.api.bgEvents.roll

    # From the SUUpdate.xml
    expect(guts.bannerBasket.getBanners.map {|x| x.id}).to include("1")
    expect(guts.markerBasket.getMarkers.map {|x| x.id}).to include("1")
    expect(guts.masterMessageBasket.getMasterMessages.map {|x| x.id}).to include("1")
    # Make sure rates get updated
    expect(api.updateRate).to eq(30000)
    expect(api.syncRate).to eq(100000)
  end

end

