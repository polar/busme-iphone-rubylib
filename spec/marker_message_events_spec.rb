require "spec_helper"
require "test_platform_api"
require 'test_marker_controller'
require 'test_marker_message_foreground'

describe Platform::MarkerMessageForeground do
  let (:time_now) {Time.now}
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:badResponse) { TestHttpMessage.new(500, "Internal Error", "")}
  let(:marker_message_lit) {
    "
      <Marker id='1' version='121' lat='53.0' lon='-74.0' length='10'
              frequency='10' priority='1' expiryTime='#{(time_now + 60 * 60).to_i}'
              radius='200'
              goUrl='http://busme.us'
              iconUrl='http://something.org/pic.png'
              ><Title>Title1</Title><Description>Hello</Description>
      </Marker>
      "
  }
  let(:markerMessageURLMessage) {
    TestHttpMessage.new(200, "OK", "<a href='http://google.com'/>")
  }
  let(:markerInfo) {
    Api::MarkerInfo.new.tap do |info|
      doc = REXML::Document.new(marker_message_lit)
      tag = Api::Tag.new(doc.root)
      info.loadParsedXML(tag)
    end
  }
  let (:httpClient) { TestHttpClient.new }
  let (:api) {
    api = TestPlatformApi.new
    api.http_client.httpClient = httpClient
    httpClient.mock_answer = suGet

    api.forceGet
    api
  }
  let(:markerController) {TestMarkerController.new }
  let(:markerMessageBackground) { Platform::MarkerMessageBackground.new(api) }
  let(:markerMessageForeground) {TestMarkerMessageForeground.new(api, markerController) }
  let(:eventData) { Platform::MarkerMessageEventData.new(markerInfo)}
  let(:markerStore) { Platform::MarkerStore.new }
  let(:markerBasket) { Platform::MarkerBasket.new(markerStore, markerController) }
  let(:location1) do
    loc = Platform::Location.new("")
    loc.latitude = 53.0
    loc.longitude = -74.0
    loc
  end
  before do
    markerMessageBackground
    markerMessageForeground
  end

  it "should with good message obey the protocol all the way through" do
    # MarkerMessage Event has been set up with a markerMessage's message to be displayed.
    api.uiEvents.postEvent("MarkerMessageEvent", eventData)

    # Foreground Thread
    api.uiEvents.roll()
    expect(markerMessageForeground.test_previous_state).to eq(Platform::MarkerMessageEventData::S_PRESENT)
    expect(eventData.state).to eq(Platform::MarkerMessageEventData::S_PRESENT)
    expect(eventData.markerMessageForeground).to eq(markerMessageForeground)

    # Call from Foreground Thread with resolve info
    eventData.markerMessageForeground.onInquired(eventData, Platform::MarkerMessageEventData::R_GO)

    # Should have added a Background Event to GO to the URL
    expect(eventData.resolve).to eq(Platform::MarkerMessageEventData::R_GO)
    expect(eventData.state).to eq(Platform::MarkerMessageEventData::S_INQUIRED)

    # Background Thread
    httpClient.mock_answer = markerMessageURLMessage
    api.bgEvents.roll()
    expect(eventData.thruUrl).to eq("http://google.com")

    # Foreground Thread
    api.uiEvents.roll()
    expect(markerMessageForeground.test_previous_state).to eq(Platform::MarkerMessageEventData::S_RESOLVED)
    expect(markerMessageForeground.test_url).to eq("http://google.com")
    expect(eventData.state).to eq(Platform::MarkerMessageEventData::S_DONE)

    # Background Thread
    api.bgEvents.roll()

    # Foreground Thread
    markerMessageForeground.test_previous_state = nil
    api.uiEvents.roll()
    expect(markerMessageForeground.test_previous_state).to eq(Platform::MarkerMessageEventData::S_DONE)
  end

  it "should obey the protocol all the way through, but with a bad response from the server, should just go to the goUrl" do
    # MarkerMessage Event has been set up with a markerMessage's message to be displayed.
    api.uiEvents.postEvent("MarkerMessageEvent", eventData)

    # Foreground Thread
    api.uiEvents.roll()
    expect(markerMessageForeground.test_previous_state).to eq(Platform::MarkerMessageEventData::S_PRESENT)
    expect(eventData.state).to eq(Platform::MarkerMessageEventData::S_PRESENT)
    expect(eventData.markerMessageForeground).to eq(markerMessageForeground)

    # Call from Foreground Thread with resolve info
    eventData.markerMessageForeground.onInquired(eventData, Platform::MarkerMessageEventData::R_GO)

    # Should have added a Background Event to GO to the URL
    expect(eventData.resolve).to eq(Platform::MarkerMessageEventData::R_GO)
    expect(eventData.state).to eq(Platform::MarkerMessageEventData::S_INQUIRED)

    # Background Thread
    httpClient.mock_answer = badResponse
    api.bgEvents.roll()
    expect(eventData.thruUrl).to eq("http://busme.us")

    # Foreground Thread
    api.uiEvents.roll()
    expect(markerMessageForeground.test_previous_state).to eq(Platform::MarkerMessageEventData::S_RESOLVED)
    expect(markerMessageForeground.test_url).to eq("http://busme.us")
    expect(eventData.state).to eq(Platform::MarkerMessageEventData::S_DONE)

    # Background Thread
    api.bgEvents.roll()

    # Foreground Thread
    markerMessageForeground.test_previous_state = nil
    api.uiEvents.roll()
    expect(markerMessageForeground.test_previous_state).to eq(Platform::MarkerMessageEventData::S_DONE)
  end

  it "should interact with basket and be removed" do
    markerBasket.addMarker(markerInfo)
    markerBasket.onLocationUpdate(location1, Time.now)
    # Foreground Thread
    markerController.roll()
    expect(markerInfo.displayed).to eq(true)
    # Event Data represents the marker being depressed to get the marker message
    api.uiEvents.postEvent("MarkerMessageEvent", eventData)
    # Foreground Thread
    api.uiEvents.roll()
    # Call from Foreground Thread with resolve info
    eventData.markerMessageForeground.onInquired(eventData, Platform::MarkerMessageEventData::R_REMOVE)
    expect(eventData.resolve).to eq(Platform::MarkerMessageEventData::R_REMOVE)
    # Background Thread
    api.bgEvents.roll()
    # Foreground Thread
    api.uiEvents.roll()

    # Marker has been removed
    expect(markerInfo.displayed).to eq(false)
  end

  it "should interact with basket and be removed, but reminded" do
    markerBasket.addMarker(markerInfo)
    markerBasket.onLocationUpdate(location1, Time.now)
    # Foreground Thread
    markerController.roll()
    expect(markerInfo.displayed).to eq(true)
    # Event Data represents the marker being depressed to get the marker message
    api.uiEvents.postEvent("MarkerMessageEvent", eventData)
    # Foreground Thread
    api.uiEvents.roll()
    # Call from Foreground Thread with resolve info
    eventData.markerMessageForeground.onInquired(eventData, Platform::MarkerMessageEventData::R_REMIND)
    expect(eventData.resolve).to eq(Platform::MarkerMessageEventData::R_REMIND)
    # Background Thread
    api.bgEvents.roll()
    # Foreground Thread
    api.uiEvents.roll()

    # Marker has been removed
    expect(markerInfo.displayed).to eq(false)
  end

  it "should remain when canceled" do
    markerBasket.addMarker(markerInfo)
    markerBasket.onLocationUpdate(location1, Time.now)
    # Foreground Thread
    markerController.roll()
    expect(markerInfo.displayed).to eq(true)
    # Event Data represents the marker being depressed to get the marker message
    api.uiEvents.postEvent("MarkerMessageEvent", eventData)
    # Foreground Thread
    api.uiEvents.roll()
    # Call from Foreground Thread with resolve info
    eventData.markerMessageForeground.onInquired(eventData, Platform::MarkerMessageEventData::R_CANCEL)
    expect(eventData.resolve).to eq(Platform::MarkerMessageEventData::R_CANCEL)
    # Background Thread
    api.bgEvents.roll()
    # Foreground Thread
    api.uiEvents.roll()

    # Marker has been removed
    expect(markerInfo.displayed).to eq(true)
  end

end