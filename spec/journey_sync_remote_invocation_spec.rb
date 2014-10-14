require "spec_helper"
require "test_platform_api"

class TestDisplay
  attr_accessor :journeys
  def initialize(api)
    api.uiEvents.registerForEvent("JourneyAdded", self)
    api.uiEvents.registerForEvent("JourneyRemoved", self)
    self.journeys = {}
  end

  def onBuspassEvent(event)
    case event.eventName
      when "JourneyAdded"
        journey = event.eventData.journeyDisplay
        journeys[journey.route.id] = journey
      when "JourneyRemoved"
        journeys.delete event.eventData.id
    end
  end
end

describe Platform::JourneySyncRemoteInvocation do
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
  let (:response2) {
    fileName = File.join("spec", "test_data", "SUUpdateWithRoutes.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:response3) {
    fileName = File.join("spec", "test_data", "SUUpdateWithRoutes2.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:display) { TestDisplay.new(api) }

  before do
    api
    guts
  end

  it "should via buspass event, get journeys and routes" do
    # From the SUGet.xml
    expect(api.updateRate.to_i).to eq(60000)
    expect(api.syncRate.to_i).to eq(60000)
    expect(display.journeys.count).to be == 0
    guts.api.mock_answer = response2

    guts.api.bgEvents.postEvent("JourneySync", Platform::UpdateEventData.new)
    guts.api.bgEvents.roll

    # Do all UI events
    while guts.api.uiEvents.roll

    end

    # From the SUUpdateWithRoutes.xml
    expect(display.journeys.values.count).to be == 2

    # The visibility controller should be in S_ROUTE, so the route should be visible
    # and the journey should not.
    journeys = display.journeys.values.select {|x| x.route.isJourney? }
    routes = display.journeys.values.select {|x| x.route.isRouteDefinition? }
    journeys.each do |journey|
      expect !journey.isNameVisible?
      expect !journey.isPathVisible?
    end
    routes.each do |route|
      expect route.isNameVisible?
      expect route.isPathVisible?
    end
  end

  it "should via buspass events, get route and journey and delete journey" do
    # From the SUGet.xml
    expect(api.updateRate.to_i).to eq(60000)
    expect(api.syncRate.to_i).to eq(60000)
    expect(display.journeys.count).to be == 0

    guts.api.mock_answer = response2
    guts.api.bgEvents.postEvent("JourneySync", Platform::UpdateEventData.new)
    guts.api.bgEvents.roll

    api.mock_answer = response3
    guts.api.bgEvents.postEvent("JourneySync", Platform::UpdateEventData.new)
    guts.api.bgEvents.roll

    # Do all UI events
    while guts.api.uiEvents.roll

    end

    # From the SUUpdateWithRoutes.xml
    expect(display.journeys.values.count).to be == 1
  end

end

