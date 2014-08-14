require "spec_helper"
require "test_api"

class TestListener
  attr_accessor :journeys_added
  attr_accessor :journeys_removed
  def onJourneyDisplayAdded(display)
    self.journeys_added ||= []
    self.journeys_added << display
  end
  def onJourneyDisplayRemoved(display)
    self.journeys_removed ||= []
    self.journeys_removed << display
  end
end

describe Platform::JourneyDisplayController do
  let(:api) { TestApi.new }
  let(:store) { Platform::JourneyStore.new }
  let(:basket) {
    basket = Platform::JourneyBasket.new(api, store)
    basket
  }
  let(:journeyDisplayController) { Platform::JourneyDisplayController.new(basket) }
  let(:controller) { Platform::JourneyVisibilityController.new(api,journeyDisplayController )}
  let(:route_id) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939597])}
  let(:journey_id) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940355])}
  let(:journey_id2) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3cb", "V", "643", 1399940355])}
  let(:route340_id) {Api::NameId.new(["340", "933043cc587f21af71c0f4803a0373e2", "R", 1399939635])}
  let(:journey340_id1) {Api::NameId.new(["340", "2d0236dbd2a072bbe7f44d8c93a6d32f", "V", "340", 1399939634])}
  let(:pattern_id) { "b2d03c4880f6d57b3b4edfa5aa9c9211"}

  before do
    controller
  end

  it "should initialize" do
    expect(controller.journeyDisplayController).to eq(journeyDisplayController)
    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ALL)
  end

  it "should have journey displays that are visible" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = journeyDisplayController.journeyDisplayMap[route_id.id]
    jd_journey = journeyDisplayController.journeyDisplayMap[journey_id.id]
    expect jd_route
    expect jd_journey

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ALL)

    expect(jd_route.pathVisible).to eq(true)
    expect(jd_route.nameVisible).to eq(true)
    # Name should not be visible.
    expect(jd_journey.pathVisible).to eq(true)
    expect(jd_journey.nameVisible).to eq(false)
  end

  it "should go to a showing only route based system"  do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = journeyDisplayController.journeyDisplayMap[route_id.id]
    jd_journey = journeyDisplayController.journeyDisplayMap[journey_id.id]

    # It should change the jd_journey to name visible.
    expect(controller.onRouteCodeSelected("643")).to eq(true)

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ROUTE)

    expect(jd_route.pathVisible).to eq(true)
    expect(jd_route.nameVisible).to eq(true)
    # Name should now be visible.
    expect(jd_journey.pathVisible).to eq(true)
    expect(jd_journey.nameVisible).to eq(true)
  end

  it "should in S_ROUTE mode add the new journey" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = journeyDisplayController.journeyDisplayMap[route_id.id]
    jd_journey = journeyDisplayController.journeyDisplayMap[journey_id.id]

    # It should change the jd_journey to name visible.
    expect(controller.onRouteCodeSelected("643")).to eq(true)

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ROUTE)

    journeyids = [route_id, journey_id, journey_id2]
    basket.sync(journeyids, nil, nil)
    jd_journey2 = journeyDisplayController.journeyDisplayMap[journey_id2.id]

    expect(jd_route.pathVisible).to eq(true)
    expect(jd_route.nameVisible).to eq(true)

    # Name should now be visible.
    expect(jd_journey.pathVisible).to eq(true)
    expect(jd_journey.nameVisible).to eq(true)

    # Name should now be visible.
    expect(jd_journey2.pathVisible).to eq(true)
    expect(jd_journey2.nameVisible).to eq(true)
  end

  it "should in S_ROUTE mode remove the 2nd journey" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = journeyDisplayController.journeyDisplayMap[route_id.id]
    jd_journey = journeyDisplayController.journeyDisplayMap[journey_id.id]

    # It should change the jd_journey to name visible.
    expect(controller.onRouteCodeSelected("643")).to eq(true)

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ROUTE)

    journeyids = [route_id, journey_id, journey_id2]
    basket.sync(journeyids, nil, nil)
    jd_journey2 = journeyDisplayController.journeyDisplayMap[journey_id2.id]
    expect jd_journey2

    journeyids = [route_id, journey_id2]
    basket.sync(journeyids, nil, nil)
    ans = journeyDisplayController.journeyDisplayMap[journey_id.id]
    expect(ans == nil)

    expect(jd_route.pathVisible).to eq(true)
    expect(jd_route.nameVisible).to eq(true)
    expect(jd_journey.pathVisible).to eq(false)
    expect(jd_journey.nameVisible).to eq(false)

    expect(jd_journey2.pathVisible).to eq(true)
    expect(jd_journey2.nameVisible).to eq(true)
  end


  it "should roll back to S_ALL with new route and journey" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = journeyDisplayController.journeyDisplayMap[route_id.id]
    jd_journey = journeyDisplayController.journeyDisplayMap[journey_id.id]

    # It should change the jd_journey to name visible.
    expect(controller.onRouteCodeSelected("643")).to eq(true)

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ROUTE)

    journeyids = [route_id, journey_id, journey_id2]
    basket.sync(journeyids, nil, nil)
    jd_journey2 = journeyDisplayController.journeyDisplayMap[journey_id2.id]
    expect jd_journey2

    journeyids = [route340_id, journey340_id1]
    basket.sync(journeyids, nil, nil)
    jd_route340 = journeyDisplayController.journeyDisplayMap[route340_id.id]
    jd_journey340 = journeyDisplayController.journeyDisplayMap[journey340_id1.id]

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ALL)
    expect(jd_route.pathVisible).to eq(false)
    expect(jd_route.nameVisible).to eq(false)
    expect(jd_journey.pathVisible).to eq(false)
    expect(jd_journey.nameVisible).to eq(false)
    expect(jd_journey2.pathVisible).to eq(false)
    expect(jd_journey2.nameVisible).to eq(false)

    expect(jd_route340.pathVisible).to eq(true)
    expect(jd_route340.nameVisible).to eq(true)
    # Name should not be visible.
    expect(jd_journey340.pathVisible).to eq(true)
    expect(jd_journey340.nameVisible).to eq(false)
  end

  it "should in S_ROUTE not show irrelevant routes" do
    journeyids = [route_id, journey_id, route340_id, journey340_id1]
    basket.sync(journeyids, nil, nil)
    jd_route340 = journeyDisplayController.journeyDisplayMap[route340_id.id]
    jd_journey340 = journeyDisplayController.journeyDisplayMap[journey340_id1.id]

    expect(jd_route340.pathVisible).to eq(true)
    expect(jd_route340.nameVisible).to eq(true)
    # Name should not be visible.
    expect(jd_journey340.pathVisible).to eq(true)
    expect(jd_journey340.nameVisible).to eq(false)

    expect(controller.onRouteCodeSelected("643")).to eq(true)

    expect(jd_route340.pathVisible).to eq(false)
    expect(jd_route340.nameVisible).to eq(false)
    # Name should not be visible.
    expect(jd_journey340.pathVisible).to eq(false)
    expect(jd_journey340.nameVisible).to eq(false)

  end

  it "should in S_ROUTE should roll back to S_ALL when selected routes are removed." do
    journeyids = [route_id, journey_id, route340_id, journey340_id1]
    basket.sync(journeyids, nil, nil)
    jd_route340 = journeyDisplayController.journeyDisplayMap[route340_id.id]
    jd_journey340 = journeyDisplayController.journeyDisplayMap[journey340_id1.id]

    expect(jd_route340.pathVisible).to eq(true)
    expect(jd_route340.nameVisible).to eq(true)
    # Name should not be visible.
    expect(jd_journey340.pathVisible).to eq(true)
    expect(jd_journey340.nameVisible).to eq(false)

    expect(controller.onRouteCodeSelected("643")).to eq(true)

    journeyids = [route340_id, journey340_id1]
    basket.sync(journeyids, nil, nil)
    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ALL)
  end


  it "should go to a showing only the only vehicle path and name"  do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = journeyDisplayController.journeyDisplayMap[route_id.id]
    jd_journey = journeyDisplayController.journeyDisplayMap[journey_id.id]

    # It should change the jd_journey to name visible.
    expect(controller.onTrackingSelected(jd_journey)).to eq(true)

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_VEHICLE)

    expect(jd_route.pathVisible).to eq(false)
    expect(jd_route.nameVisible).to eq(true)
    # Name should now be visible.
    expect(jd_journey.pathVisible).to eq(true)
    expect(jd_journey.nameVisible).to eq(true)

  end

  it "should in S_VEHICLE roll back to S_ALL when tracking route is removed"  do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = journeyDisplayController.journeyDisplayMap[route_id.id]
    jd_journey = journeyDisplayController.journeyDisplayMap[journey_id.id]

    # It should change the jd_journey to name visible.
    expect(controller.onTrackingSelected(jd_journey)).to eq(true)

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_VEHICLE)
    journeyids = [route_id]
    basket.sync(journeyids, nil, nil)

    expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ALL)

    expect(jd_route.pathVisible).to eq(true)
    expect(jd_route.nameVisible).to eq(true)
    expect(jd_journey.pathVisible).to eq(false)
    expect(jd_journey.nameVisible).to eq(false)

  end

  context "Using Location selection" do
    it "should eliminate irrelevant routes"do
      journeyids = [route_id, journey_id, route340_id, journey340_id1]
      basket.sync(journeyids, nil, nil)
      jd_route = journeyDisplayController.journeyDisplayMap[route_id.id]
      jd_journey = journeyDisplayController.journeyDisplayMap[journey_id.id]
      jd_route340 = journeyDisplayController.journeyDisplayMap[route340_id.id]
      jd_journey340 = journeyDisplayController.journeyDisplayMap[journey340_id1.id]

      # This point shouldn't match any thing other than the 340
      point1 = jd_journey340.route.paths[0][0]
      expect(controller.onLocationSelected(point1, 60)).to eq(true)

      expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ALL)
      expect(jd_route.pathVisible).to eq(false)
      expect(jd_route.nameVisible).to eq(false)
      expect(jd_journey.pathVisible).to eq(false)
      expect(jd_journey.nameVisible).to eq(false)

      expect(jd_route340.pathVisible).to eq(true)
      expect(jd_route340.nameVisible).to eq(true)
      expect(jd_journey340.pathVisible).to eq(true)
      expect(jd_journey340.nameVisible).to eq(false)
    end

    it "should eliminate routes and add them back in" do
      journeyids = [route340_id, journey340_id1]
      basket.sync(journeyids, nil, nil)
      expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ALL)
      jd_route340 = journeyDisplayController.journeyDisplayMap[route340_id.id]
      jd_journey340 = journeyDisplayController.journeyDisplayMap[journey340_id1.id]

      # This point shouldn't match any thing other than the 340
      point1 = jd_journey340.route.paths[0][0]
      expect(controller.onLocationSelected(point1, 60)).to eq(true)
      expect(controller.stateStack.peek.state).to eq(Platform::VisualState::S_ALL)

      expect(jd_route340.pathVisible).to eq(true)
      expect(jd_route340.nameVisible).to eq(true)
      expect(jd_journey340.pathVisible).to eq(true)
      expect(jd_journey340.nameVisible).to eq(false)

      journeyids = [route340_id]
      basket.sync(journeyids, nil, nil)
      expect(jd_journey340.pathVisible).to eq(false)
      expect(jd_journey340.nameVisible).to eq(false)

      journeyids = [route340_id, journey340_id1]
      basket.sync(journeyids, nil, nil)
      jd_journey340 = journeyDisplayController.journeyDisplayMap[journey340_id1.id]

      # It gets redisplayed merely because it's a 340, regardless of location.
      expect(jd_journey340.pathVisible).to eq(true)
      expect(jd_journey340.nameVisible).to eq(false)

    end
  end

  it "should create journey displays and abandon them" do
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
    basket.sync([], nil, nil)
    expect(controller.test_presented_journey_displays).to_not include(jd_route)
    expect(controller.test_presented_journey_displays).to_not include(jd_journey)
  end

  it "should create journey displays and hit added listeners" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    expect(controller.journeyDisplayMap.keys).to include(route_id.id)
    expect(controller.journeyDisplayMap.keys).to include(journey_id.id)
    jd_route = controller.journeyDisplayMap[route_id.id]
    jd_journey = controller.journeyDisplayMap[journey_id.id]
    expect jd_route
    expect jd_journey
    expect(listener.journeys_added).to include(jd_route)
    expect(listener.journeys_added).to include(jd_journey)
  end

  it "should create journey displays and hit removed listeners for the journey not included" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    expect(controller.journeyDisplayMap.keys).to include(route_id.id)
    expect(controller.journeyDisplayMap.keys).to include(journey_id.id)
    jd_route = controller.journeyDisplayMap[route_id.id]
    jd_journey = controller.journeyDisplayMap[journey_id.id]
    expect jd_route
    expect jd_journey
    expect(listener.journeys_added).to include(jd_route)
    expect(listener.journeys_added).to include(jd_journey)
    # Should remove journey_id
    basket.sync([route_id], nil, nil)
    expect(listener.journeys_removed).to_not include(jd_route)
    expect(listener.journeys_removed).to include(jd_journey)
  end

  it "should make the display of route to have its related journey as an active" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)
    jd_route = controller.journeyDisplayMap[route_id.id]
    jd_journey = controller.journeyDisplayMap[journey_id.id]
    expect(jd_route.hasActiveJourneys?)
    expect(jd_route.activeJourneys).to include(jd_journey)
  end

end