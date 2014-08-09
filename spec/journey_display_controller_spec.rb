require "spec_helper"
require "test_api"
require "test_journey_display_controller"

describe Platform::JourneyDisplayController do
  let(:api) { TestApi.new }
  let(:store) { Platform::JourneyStore.new }
  let(:basket) {
    basket = Platform::JourneyBasket.new(api, store)
    basket
  }
  let(:controller) {
    TestJourneyDisplayController.new(basket)
  }
  let(:route_id) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939597])}
  let(:journey_id) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940355])}
  let(:route_id2) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939598])}
  let(:journey_id2) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940356])}
  let(:pattern_id) { "b2d03c4880f6d57b3b4edfa5aa9c9211"}

  it "should initialize" do
    controller.onCreate
    expect(basket.onJourneyAddedListener).to eq(controller)
    expect(basket.onJourneyRemovedListener).to eq(controller)
  end

  it "should create journey displays and present them" do
    controller.onCreate
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    expect(controller.journeyDisplayMap.keys).to include(route_id.id)
    expect(controller.journeyDisplayMap.keys).to include(journey_id.id)
    jd_route = controller.journeyDisplayMap[route_id.id]
    jd_journey = controller.journeyDisplayMap[journey_id.id]
    expect jd_route
    expect jd_journey
    expect(controller.test_presented_journey_displays).to include(jd_route)
    expect(controller.test_presented_journey_displays).to include(jd_journey)
  end

  it "should make the display of route to have its related journey as an active" do
    controller.onCreate
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = controller.journeyDisplayMap[route_id.id]
    jd_journey = controller.journeyDisplayMap[journey_id.id]
    expect(jd_route.hasActiveJourneys?)
    expect(jd_route.activeJourneys).to include(jd_journey)
  end

end