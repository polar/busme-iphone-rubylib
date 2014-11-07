require "spec_helper"
require "test_platform_api"

class TestFG_BannerMessageEventController < Platform::FG_BannerMessageEventController
  attr_accessor :test_previous_state

  def onInquireStart(requestState)
    self.test_previous_state = requestState.state
    super(requestState)
  end

  def onNotifyStart(requestState)
    self.test_previous_state = requestState.state
    # Simulate the user clicking the popup away
    requestState.state = S_FINISH
    api.bgEvents.postEvent("BannerMessage", requestState)
  end
end

describe Platform::BannerMessageEventData do
  let (:time_now) {Utils::Time.current}
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
  let (:api) {
    api = TestPlatformApi.new
    api.mock_answer = suGet

    api.forceGet
    api
  }
  let(:bannerBackground) { Platform::BG_BannerMessageEventController.new(api) }
  let(:bannerForeground) {TestFG_BannerMessageEventController.new(api) }
  before do
    bannerBackground
    bannerForeground
  end

  it "should with good message obey the protocol all the way through" do
    eventData =  Platform::BannerMessageEventData.new(banner)
    # Banner Event has been set up with a banner's message to be displayed.
    api.uiEvents.postEvent("BannerMessage", eventData)

    # Foreground Thread
    api.uiEvents.roll()
    # Above we transitioned it from S_START all the way to S_ANSWER_FINISH
    expect(bannerForeground.test_previous_state).to eq(Platform::RequestConstants::S_INQUIRE_START)
    expect(eventData.state).to eq(Platform::RequestConstants::S_REQUEST_START)

    # Should have added a Background Event to GO to the URL
    api.bgEvents.top()
    expect(eventData.state).to eq(Platform::RequestConstants::S_REQUEST_START)
    expect(eventData.resolve).to eq(Platform::BannerMessageConstants::R_GO)

    # Background Thread
    api.mock_answer = bannerURLMessage
    api.bgEvents.roll()

    # Foreground Thread
    bannerForeground.test_previous_state = nil
    api.uiEvents.roll()
    expect(bannerForeground.test_previous_state).to eq(Platform::RequestConstants::S_NOTIFY_START)
    expect(eventData.thruUrl).to eq("http://google.com")

    # Background Thread
    api.bgEvents.roll()
    expect(eventData.state).to eq(Platform::RequestConstants::S_FINISH)
  end

  it "should with bad response, it should still obey the protocol all the way through, but should pick up the goURL" do
    eventData =  Platform::BannerMessageEventData.new(banner)
    # Banner Event has been set up with a banner's message to be displayed.
    api.uiEvents.postEvent("BannerMessage", eventData)

    # Foreground Thread
    api.uiEvents.roll()
    # Above we transitioned it from S_START all the way to S_ANSWER_FINISH
    expect(bannerForeground.test_previous_state).to eq(Platform::RequestConstants::S_INQUIRE_START)
    expect(eventData.state).to eq(Platform::RequestConstants::S_REQUEST_START)

    # Should have added a Background Event to GO to the URL
    api.bgEvents.top()
    expect(eventData.state).to eq(Platform::RequestConstants::S_REQUEST_START)
    expect(eventData.resolve).to eq(Platform::BannerMessageConstants::R_GO)

    # Background Thread
    api.mock_answer = badResponse
    api.bgEvents.roll()

    # Foreground Thread
    bannerForeground.test_previous_state = nil
    api.uiEvents.roll()
    expect(bannerForeground.test_previous_state).to eq(Platform::RequestConstants::S_NOTIFY_START)
    expect(eventData.thruUrl).to eq("http://busme.us")

    # Background Thread
    api.bgEvents.roll()
    expect(eventData.state).to eq(Platform::RequestConstants::S_FINISH)
  end

end