require "spec_helper"
require "test_platform_api"

class TestFGJourneySyncProgressController < Platform::FG_JourneySyncProgressEventController
  attr_accessor :test_onBegin
  attr_accessor :test_onSyncStart
  attr_accessor :test_onSyncEnd
  attr_accessor :test_onRouteStart
  attr_accessor :test_onRouteEnd
  attr_accessor :test_onDone
  def initialize(api); super(api); self.test_onRouteStart = []; self.test_onRouteEnd = []; end
  def onBegin(eventData); self.test_onBegin = eventData; end
  def onSyncStart(eventData); self.test_onSyncStart = eventData; end
  def onSyncEnd(eventData); self.test_onSyncEnd = eventData; end
  def onRouteStart(eventData); self.test_onRouteStart[eventData.iRoute] = eventData; end
  def onRouteEnd(eventData); self.test_onRouteEnd[eventData.iRoute] = eventData; end
  def onDone(eventData); self.test_onDone = eventData; end
end

# This class just eats up the JourneyAdded events.
class DummyListener
  def initialize(api)
    api.uiEvents.registerForEvent("JourneyAdded", self)
  end
  def onBuspassEvent(event)
  end
end

describe Platform::FG_JourneySyncProgressEventController do
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:api) {
    api = TestPlatformApi.new
    api.mock_answer = suGet

    api.forceGet
    api
  }
  let(:store) { Platform::JourneyStore.new }
  let(:basket) {
    basket = Platform::JourneyBasket.new(api, store)
    basket
  }
  let(:journeyDisplayController) { Platform::JourneyDisplayController.new(api, basket) }
  let(:controller) { Platform::BG_JourneySyncController.new(api,journeyDisplayController )}
  let(:route_id) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939597])}
  let(:journey_id) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940355])}
  let(:journey_id2) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3cb", "V", "643", 1399940355])}
  let(:route340_id) {Api::NameId.new(["340", "933043cc587f21af71c0f4803a0373e2", "R", 1399939635])}
  let(:journey340_id1) {Api::NameId.new(["340", "2d0236dbd2a072bbe7f44d8c93a6d32f", "V", "340", 1399939634])}
  let(:journey340_id2) {Api::NameId.new(["340", "451d7074f1580e1224eeef8dbab8ac36", "V", "340", 1399939634])}
  let(:journey340_id3) {Api::NameId.new(["340", "556e3d48986d2cefbfce3b80abda2695", "V", "340", 1399939628])}
  let(:pattern_id) { "b2d03c4880f6d57b3b4edfa5aa9c9211"}
  let(:httpClient) { api.http_client.httpClient }

  let(:responseData) { "
    <Response>
     <R>#{route_id.name},#{route_id.id},#{route_id.type},#{route_id.version}</R>
     <R>#{route340_id.name},#{route340_id.id},#{route340_id.type},#{route340_id.version}</R>
     <J>#{journey_id.name},#{journey_id.id},#{journey_id.type},#{journey_id.route_id},#{journey_id.version}</J>
     <J>#{journey_id2.name},#{journey_id2.id},#{journey_id2.type},#{journey_id2.route_id},#{journey_id2.version}</J>
     <J>#{journey340_id1.name},#{journey340_id1.id},#{journey340_id1.type},#{journey340_id1.route_id},#{journey340_id1.version}</J>
     <J>#{journey340_id2.name},#{journey340_id2.id},#{journey340_id2.type},#{journey340_id2.route_id},#{journey340_id2.version}</J>
     <J>#{journey340_id3.name},#{journey340_id3.id},#{journey340_id3.type},#{journey340_id3.route_id},#{journey340_id3.version}</J>
    </Response>"
  }

  let(:response) { TestHttpMessage.new(200, "OK", responseData)}

  let(:fgController) { TestFGJourneySyncProgressController.new(api)}
  let(:dummyListener) { DummyListener.new(api)}

  before do
    controller
    dummyListener
    fgController
  end

  it "should initialize" do
    expect(controller.journeyDisplayController).to eq(journeyDisplayController)
  end

  it "should accept an event and get all journeys" do
    evd = Platform::JourneySyncEventData.new()
    evd.isForced = true
    api.bgEvents.postEvent("JourneySync", evd)

    api.mock_answer = response
    api.bgEvents.roll

    expect(store.journeys.size).to eq(7)
  end

  it "should accept an event and produce a protocol of events" do
    evd = Platform::JourneySyncEventData.new()
    evd.isForced = true
    api.bgEvents.postEvent("JourneySync", evd)

    api.mock_answer = response
    api.bgEvents.roll

    api.uiEvents.roll
    expect(fgController.test_onBegin).to_not eq(nil)
    api.uiEvents.roll
    expect(fgController.test_onSyncStart).to_not eq(nil)
    api.uiEvents.roll
    expect(fgController.test_onSyncEnd).to_not eq(nil)
    expect(fgController.test_onSyncEnd.nRoutes).to eq(7)
    api.uiEvents.rollAll
    for i in 0..fgController.test_onSyncEnd.nRoutes-1 do
      expect(fgController.test_onRouteStart[i]).to_not eq(nil)
      expect(fgController.test_onRouteStart[i].iRoute).to eq(i)
      expect(fgController.test_onRouteEnd[i]).to_not eq(nil)
      expect(fgController.test_onRouteEnd[i].iRoute).to eq(i)
    end
    expect(fgController.test_onDone).to_not eq(nil)
  end

end