require "spec_helper"
require "test_api"
require "test_journey_display_controller"


describe Platform::JourneyCurrentLocationsRequestProcessor do
  let(:api) { TestApi.new }
  let(:store) { Platform::JourneyStore.new }
  let(:basket) {
    basket = Platform::JourneyBasket.new(api, store)
  }
  let(:controller) { TestJourneyDisplayController.new(api, basket)}
  let(:processor) { Platform::JourneyCurrentLocationsRequestProcessor.new(controller) }
  let(:route_id) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939597])}
  let(:journey_id) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940355])}
  let(:route_id2) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939598])}
  let(:journey_id2) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940356])}
  let(:pattern_id) { "b2d03c4880f6d57b3b4edfa5aa9c9211"}
  let(:response1) {
    lit = "<Response>
            <JPS>
              <JP id='968f501b3e02890cffa2a1e1b80bc3ca' lon='-76.131502' lat='43.037292' />
            </JPS>
           </Response>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
  }
  let(:response2) {
    lit = "<Response>
            <JPS>
              <JP id='968f501b3e02890cffa2a1e1b80bc3ca' lon='-76.140683' lat='43.037399' />
            </JPS>
           </Response>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
  }

  before do
    # Need to instantiate controller for each spec
    controller
  end

  it "should replace journeys" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)

    journey = store.getJourney(journey_id.id)
    expect journey


    expect(processor.getArguments).to include(["journey_ids[]", journey_id.id])

    processor.onResponse(response1)
    expect Platform::GeoCalc.equalCoordinates(journey.lastKnownLocation,
                                              Integration::GeoPoint.new(43.037292 * 1E6, -76.131502 * 1E6))
    processor.onResponse(response2)
    expect Platform::GeoCalc.equalCoordinates(journey.lastKnownLocation,
                                              Integration::GeoPoint.new(43.037399 * 1E6, --76.140683 * 1E6))
  end
end