require "spec_helper"
require "test_platform_api"

class TestMasterMessageForground < Platform::FG_MasterMessageEventController
  attr_accessor :test_previous_state

  def onInquireStart(requestState)
    test_previous_state = requestState.state
  end

  def onNotifyStart(requestState)

  end
end

describe Platform::MasterMessageForeground do
  let (:time_now) {Time.now}
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:badResponse) { TestHttpMessage.new(500, "Internal Error", "")}
  let(:master_message_lit) {
    "
      <MasterMessage id='1' version='121' lat='53.0' lon='-73.0' length='10'
              frequency='10' priority='1' expiryTime='#{time_now.to_i}'
              radius='200'
              goUrl='http://busme.us'
              iconUrl='http://something.org/pic.png'
              ><Title>Title1</Title><Description>Hello</Description>
      </MasterMessage>
      "
  }
  let(:masterMessageURLMessage) {
    TestHttpMessage.new(200, "OK", "<a href='http://google.com'/>")
  }
  let(:masterMessage) {
    Api::MasterMessage.new.tap do |info|
      doc = REXML::Document.new(master_message_lit)
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
  let(:masterMessageBackground) { Platform::BG_MasterMessageEventController.new(api) }
  let(:masterMessageForeground) {TestMasterMessageForeground.new(api) }
  let(:eventData) { Platform::MasterMessageEventData.new(masterMessage)}
  before do
    masterMessageBackground
    masterMessageForeground
  end

  it "should obey the protocol all the way through" do
    # MasterMessage Event has been set up with a masterMessage's message to be displayed.
    api.bgEvents.postEvent("MasterMessage", eventData)

    api.bgEvents.roll()


    # Foreground Thread
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::MasterMessageEventData::S_PRESENT)
    expect(eventData.state).to eq(Platform::MasterMessageEventData::S_PRESENT)
    expect(eventData.masterMessageForeground).to eq(masterMessageForeground)
    expect(masterMessage.displayed).to eq(true)

    # Call from Foreground Thread with resolve info
    eventData.masterMessageForeground.onInquired(eventData, Platform::MasterMessageEventData::R_GO)

    # Should have added a Background Event to GO to the URL
    expect(eventData.resolve).to eq(Platform::MasterMessageEventData::R_GO)
    expect(eventData.state).to eq(Platform::MasterMessageEventData::S_INQUIRED)

    # Background Thread
    httpClient.mock_answer = masterMessageURLMessage
    api.bgEvents.roll()
    expect(eventData.thruUrl).to eq("http://google.com")

    # Foreground Thread
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::MasterMessageEventData::S_RESOLVED)
    expect(masterMessageForeground.test_url).to eq("http://google.com")
    expect(eventData.state).to eq(Platform::MasterMessageEventData::S_DONE)

    # Background Thread
    api.bgEvents.roll()

    # Foreground Thread
    masterMessageForeground.test_previous_state = nil
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::MasterMessageEventData::S_DONE)

    # The dismiss might happen before, but it should definitely be dismissed by now.
    expect(masterMessage.displayed).to eq(false)
  end

  it "should obey the protocol all the way through, but with a bad response from the server, should just go to the goUrl" do
    # MasterMessage Event has been set up with a masterMessage's message to be displayed.
    api.uiEvents.postEvent("MasterMessageEvent", eventData)

    # Foreground Thread
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::MasterMessageEventData::S_PRESENT)
    expect(eventData.state).to eq(Platform::MasterMessageEventData::S_PRESENT)
    expect(eventData.masterMessageForeground).to eq(masterMessageForeground)

    # Call from Foreground Thread with resolve info
    eventData.masterMessageForeground.onInquired(eventData, Platform::MasterMessageEventData::R_GO)

    # Should have added a Background Event to GO to the URL
    expect(eventData.resolve).to eq(Platform::MasterMessageEventData::R_GO)
    expect(eventData.state).to eq(Platform::MasterMessageEventData::S_INQUIRED)

    # Background Thread
    httpClient.mock_answer = badResponse
    api.bgEvents.roll()
    expect(eventData.thruUrl).to eq("http://busme.us")

    # Foreground Thread
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::MasterMessageEventData::S_RESOLVED)
    expect(masterMessageForeground.test_url).to eq("http://busme.us")
    expect(eventData.state).to eq(Platform::MasterMessageEventData::S_DONE)

    # Background Thread
    api.bgEvents.roll()

    # Foreground Thread
    masterMessageForeground.test_previous_state = nil
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::MasterMessageEventData::S_DONE)

    # The dismiss might happen before, but it should definitely be dismissed by now.
    expect(masterMessage.displayed).to eq(false)
  end

end