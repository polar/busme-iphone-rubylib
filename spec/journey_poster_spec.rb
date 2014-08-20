require "spec_helper"
require "test_platform_api"

class TestJourneyEventController < Platform::JourneyEventController
  attr_accessor :eventData
  attr_accessor :location
  attr_accessor :action

  def onRoutePosting(eventData)
    self.eventData = eventData
    self.action = eventData.action
    self.location = eventData.location
  end
  def atRouteStart(eventData)
    self.eventData = eventData
    self.action = eventData.action
    self.location = eventData.location
  end
  def onOffRoute(eventData)
    self.eventData = eventData
    self.action = eventData.action
    self.location = eventData.location
  end
  def onOnRoute(eventData)
    self.eventData = eventData
    self.action = eventData.action
    self.location = eventData.location
  end
  def updateRoute(eventData)
    self.eventData = eventData
    self.action = eventData.action
    self.location = eventData.location
  end
  def atRouteEnd(eventData)
    self.eventData = eventData
    self.action = eventData.action
    self.location = eventData.location
  end
  def onRouteDone(eventData)
    self.action = eventData.action
    self.eventData = nil
    self.location = nil
  end

end

class TestJourneyPostingController < Platform::JourneyPostingController
  attr_accessor :test_posted_location
  attr_accessor :test_posted_answer

  def postLocation(eventData)
    ans = super(eventData)
    self.test_posted_location = eventData.location
    self.test_posted_answer = ans
    ans
  end
end

describe Platform::JourneyLocationPoster do
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:httpClient) { TestHttpClient.new }
  let (:api) {
    TestPlatformApi.new.tap do |theApi|
      theApi.http_client.httpClient = httpClient
      httpClient.mock_answer = suGet

      theApi.forceGet
    end
  }
  let(:store) { Platform::JourneyStore.new }
  let(:basket) {
    Platform::JourneyBasket.new(api, store)
  }
  let(:route_id) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939597])}
  let(:journey_id) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940355])}
  let(:eventController) { TestJourneyEventController.new(api) }
  let(:locationPoster) { Platform::JourneyLocationPoster.new(api) }
  let(:postingController) { TestJourneyPostingController.new(api) }

  before do
    api
    basket.sync([route_id, journey_id], nil, nil)
    eventController
    locationPoster
    postingController
  end

  it "should get route"  do
    journey = store.getJourney(journey_id.id)
    expect(journey).to_not eq(nil)
  end

  it "should run for the foreground through the protocol from start to finish"  do
    journey = store.getJourney(journey_id.id)
    expect(journey).to_not eq(nil)

    # enable it
    locationPoster.enabled = true
    locationPoster.startPosting(journey, "driver")

    path = journey.paths[0]
    iPoint = 0
    nPointsAtStart = 0
    nPointsAtEnd = 0
    # This test is obviously contrived in that every point is exactly on route.
    for point in path do
      location = Platform::Location.new("", point.longitude, point.latitude)
      location.speed = 10 * 5120 # feet per hour
      locationPoster.processLocation(location)
      while api.uiEvents.roll do
        case eventController.action
          when Platform::JourneyEventData::A_ON_ROUTE_POSTING
            expect(iPoint).to eq(0)
          when Platform::JourneyEventData::A_AT_ROUTE_START
            nPointsAtStart += 1
          when Platform::JourneyEventData::A_UPDATE_ROUTE
            # We should always get an update because we are on route with
            # these particular points.
          when Platform::JourneyEventData::A_AT_ROUTE_END
            nPointsAtEnd += 1
        end
        expect(eventController.location.latitude).to eq(point.latitude)
        expect(eventController.location.longitude).to eq(point.longitude)
      end
      iPoint += 1
    end
    # The first two points are close enough together.
    expect(nPointsAtStart).to eq(1)
    expect(nPointsAtEnd).to eq(1)
  end

  it "should run for the background posting each location from start to finish"  do
    journey = store.getJourney(journey_id.id)
    expect(journey).to_not eq(nil)

    # enable it
    locationPoster.enabled = true
    locationPoster.startPosting(journey, "driver")

    httpClient.mock_answer = TestHttpMessage.new(200, "OK","<OK/>")

    path = journey.paths[0]
    iPoint = 0
    nPointsAtStart = 0
    nPointsAtEnd = 0
    # This test is obviously contrived in that every point is exactly on route.
    for point in path do
      location = Platform::Location.new("", point.longitude, point.latitude)
      location.speed = 10 * 5120 # feet per hour
      locationPoster.processLocation(location)
      postingController.test_posted_location = nil
      postingController.test_posted_answer = nil
      api.bgEvents.roll
      expect(postingController.test_posted_answer).to eq("ok")
      expect(postingController.test_posted_location).to eq(location)
    end
  end

end
