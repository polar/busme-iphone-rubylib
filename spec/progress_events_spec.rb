require "spec_helper"
require "test_platform_api"

class TestProgressForeground < Platform::ProgressForeground
  attr_accessor :eventData
  attr_accessor :nRoutes
  attr_accessor :iRoute

  def onSyncStart(eventData)
    self.eventData = eventData
  end
  def onSyncEnd(eventData)
    self.eventData = eventData
    self.nRoutes = eventData.nRoutes
  end
  def onRouteStart(eventData)
    self.eventData = eventData
    self.iRoute = eventData.iRoute
  end
  def onRouteEnd(eventData)
    self.eventData = eventData
    self.iRoute = -iRoute
  end
  def onDone(eventData)
    self.eventData = nil
  end

end

describe Platform::JourneyVisibilityController do
  let(:api) { TestPlatformApi.new }
  let(:store) { Platform::JourneyStore.new }
  let(:basket) {
    basket = Platform::JourneyBasket.new(api, store)
    basket
  }
  let(:route_id) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939597])}
  let(:journey_id) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940355])}
  let(:journey_id2) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3cb", "V", "643", 1399940355])}
  let(:route340_id) {Api::NameId.new(["340", "933043cc587f21af71c0f4803a0373e2", "R", 1399939635])}
  let(:journey340_id1) {Api::NameId.new(["340", "2d0236dbd2a072bbe7f44d8c93a6d32f", "V", "340", 1399939634])}
  let(:journey340_id2) {Api::NameId.new(["340", "451d7074f1580e1224eeef8dbab8ac36", "V", "340", 1399939634])}
  let(:journey340_id3) {Api::NameId.new(["340", "556e3d48986d2cefbfce3b80abda2695", "V", "340", 1399939628])}
  let(:pattern_id) { "b2d03c4880f6d57b3b4edfa5aa9c9211"}
  let(:progressForeground) { TestProgressForeground.new(api) }
  let(:progressBackground) { Platform::ProgressBackground.new(api) }

  before do
    progressForeground
    progressBackground
  end


  it "should cause foreground events in order for the sync to operate the progress indicator" do
    journeyids = [route_id, journey_id, journey_id2, route340_id, journey340_id1, journey340_id2, journey340_id3]

    # This will be the protocol on a full update.
    progressBackground.onSyncStart
    progressBackground.onSyncEnd(journeyids.length)

    basket.sync(journeyids, progressBackground, nil)
    progressBackground.onDone()

    api.uiEvents.roll
    expect(progressForeground.eventData).to_not eq(nil)
    api.uiEvents.roll
    expect(progressForeground.nRoutes).to eq(journeyids.length)
    for i in 0..journeyids.length-1
      api.uiEvents.roll
      expect(progressForeground.iRoute).to eq(i)
      api.uiEvents.roll
      expect(progressForeground.iRoute).to eq(-i)
    end
    api.uiEvents.roll
    expect(progressForeground.eventData).to eq(nil)
  end

end