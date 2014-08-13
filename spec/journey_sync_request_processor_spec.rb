require "spec_helper"
require "test_api"
require "test_http_client"
require "test_basket_listener"


describe Platform::JourneySyncRequestProcessor do
  let(:api) { TestApi.new }
  let(:store) { Platform::JourneyStore.new }
  let(:listener) { TestBasketListener.new }
  let(:basket) {
    basket = Platform::JourneyBasket.new(api, store)
    basket
  }
  let(:controller) { Platform::JourneyDisplayController.new(basket) }
  let(:processor) {
    Platform::JourneySyncRequestProcessor.new(controller).tap do
      # The contoller sets the onJourneyAddedListener and onJourneyRemovedListener
      basket.onJourneyAddedListener = listener
      basket.onJourneyRemovedListener = listener
      basket.onBasketUpdateListener = listener
    end
  }
  let(:route_id) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939597])}
  let(:journey_id) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940355])}
  let(:route_id2) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939598])}
  let(:journey_id2) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940356])}
  let(:pattern_id) { "b2d03c4880f6d57b3b4edfa5aa9c9211"}
  let(:response) {
    lit = "<Response>
              <R>643,9864eb9e615f740526e93f6297e29435,R,1399939598</R>
              <J>643,968f501b3e02890cffa2a1e1b80bc3ca,V,643,1399940356</J>
           </Response>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
  }

  it "should replace journeys" do
    journeyids = [route_id, journey_id]
    basket.sync(journeyids, nil, nil)

    expect(processor.getArguments).to eq([])

    processor.onResponse(response)

    expect !store.containsJourney?(route_id.id)
    expect !store.containsJourney?(journey_id.id)

    expect store.containsJourney?(route_id2.id)
    expect(store.getJourney(route_id2.id).version).to eq(route_id2.version)

    expect store.containsJourney?(journey_id2.id)
    expect(store.getJourney(journey_id2.id).version).to eq(journey_id2.version)

    expect store.containsPattern?(pattern_id)
  end
end