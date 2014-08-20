require "spec_helper"
require "test_platform_api"
require 'test_banner_foreground'

describe Platform::BannerForeground do
  let (:time_now) {Time.now}
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:badResponse) { TestHttpMessage.new(500, "Internal Error", "")}
  let(:banner_lit) {
    "
      <Banner id='1' version='121' lat='53.0' lon='-73.0' length='10'
              frequency='10' priority='1' expiryTime='#{time_now.to_i}'
              radius='200'
              goUrl='http://busme.us'
              iconUrl='http://something.org/pic.png'
              ><Title>Title1</Title><Description>Hello</Description>
      </Banner>
      "
  }
  let(:bannerURLMessage) {
    TestHttpMessage.new(200, "OK", "<a href='http://google.com'/>")
  }
  let(:banner) {
    Api::BannerInfo.new.tap do |info|
      doc = REXML::Document.new(banner_lit)
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
  let(:bannerBackground) { Platform::BannerBackground.new(api) }
  let(:bannerForeground) {TestBannerForeground.new(api) }
  before do
    bannerBackground
    bannerForeground
  end

  it "should with good message obey the protocol all the way through" do
    eventData =  Platform::BannerEventData.new(banner)
    # Banner Event has been set up with a banner's message to be displayed.
    api.uiEvents.postEvent("BannerEvent", eventData)

    # Foreground Thread
    event = api.uiEvents.roll()
    eventData = event.eventData
    expect(bannerForeground.test_previous_state).to eq(Platform::BannerEventData::S_PRESENT)
    expect(eventData.state).to eq(Platform::BannerEventData::S_PRESENT)
    expect(eventData.bannerForeground).to eq(bannerForeground)

    expect(banner.displayed).to eq(true)

    # Call from Foreground Thread with resolve info
    eventData.bannerForeground.onInquired(eventData,Platform::BannerEventData::R_GO)

    # Should have added a Background Event to GO to the URL
    event = api.bgEvents.top()
    eventData = event.eventData
    expect(eventData.resolve).to eq(Platform::BannerEventData::R_GO)
    expect(eventData.state).to eq(Platform::BannerEventData::S_INQUIRED)

    # Background Thread
    httpClient.mock_answer = bannerURLMessage
    event = api.bgEvents.roll()
    eventData = event.eventData

    event = api.uiEvents.top
    eventData = event.eventData
    expect(eventData.thruUrl).to eq("http://google.com")
    expect(eventData.state).to eq(Platform::BannerEventData::S_RESOLVED)

    # Foreground Thread
    bannerForeground.test_previous_state = nil
    event = api.uiEvents.roll()
    eventData = event.eventData
    expect(bannerForeground.test_previous_state).to eq(Platform::BannerEventData::S_RESOLVED)
    expect(bannerForeground.test_url).to eq("http://google.com")

    # Background Thread
    event = api.bgEvents.roll()
    eventData = event.eventData
    expect(eventData.state).to eq(Platform::BannerEventData::S_DONE)

    # Foreground Thread
    bannerForeground.test_previous_state = nil
    event = api.uiEvents.roll()
    eventData = event.eventData
    expect(bannerForeground.test_previous_state).to eq(Platform::BannerEventData::S_DONE)

    # The dismiss might happen before, but it should definitely be dismissed by now.
    expect(banner.displayed).to eq(false)
  end

  it "should with bad repsonse, it should still obey the protocol all the way through, but should pick up the goURL" do
    eventData =  Platform::BannerEventData.new(banner)
    # Banner Event has been set up with a banner's message to be displayed.
    api.uiEvents.postEvent("BannerEvent", eventData)

    # Foreground Thread
    event = api.uiEvents.roll()
    eventData = event.eventData
    expect(bannerForeground.test_previous_state).to eq(Platform::BannerEventData::S_PRESENT)
    expect(eventData.state).to eq(Platform::BannerEventData::S_PRESENT)
    expect(eventData.bannerForeground).to eq(bannerForeground)

    expect(banner.displayed).to eq(true)

    # Call from Foreground Thread with resolve info
    eventData.bannerForeground.onInquired(eventData, Platform::BannerEventData::R_GO)

    # Should have added a Background Event to GO to the URL
    event = api.bgEvents.top
    eventData = event.eventData
    expect(eventData.resolve).to eq(Platform::BannerEventData::R_GO)
    expect(eventData.state).to eq(Platform::BannerEventData::S_INQUIRED)

    # Background Thread
    httpClient.mock_answer = badResponse
    event = api.bgEvents.roll
    eventData = event.eventData
    expect(eventData.resolve).to eq(Platform::BannerEventData::R_GO)
    expect(eventData.state).to eq(Platform::BannerEventData::S_INQUIRED)

    event = api.uiEvents.top
    eventData = event.eventData
    expect(eventData.thruUrl).to eq("http://busme.us")
    expect(eventData.state).to eq(Platform::BannerEventData::S_RESOLVED)

    # Foreground Thread
    bannerForeground.test_previous_state = nil
    event = api.uiEvents.roll
    eventData = event.eventData
    expect(bannerForeground.test_previous_state).to eq(Platform::BannerEventData::S_RESOLVED)
    expect(bannerForeground.test_url).to eq("http://busme.us")

    # Background Thread
    event = api.bgEvents.roll
    eventData = event.eventData
    expect(eventData.state).to eq(Platform::BannerEventData::S_DONE)

    # Foreground Thread
    bannerForeground.test_previous_state = nil
    api.uiEvents.roll()
    expect(bannerForeground.test_previous_state).to eq(Platform::BannerEventData::S_DONE)

    # The dismiss might happen before, but it should definitely be dismissed by now.
    expect(banner.displayed).to eq(false)
  end

end