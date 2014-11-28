require "spec_helper"
require "test_platform_api"

class TestFGMasterMessageEventController < Platform::FG_MasterMessageEventController
  attr_accessor :test_previous_state

  def onInquireStart(requestState)
    self.test_previous_state = requestState.state
    super
  end

  def onNotifyStart(requestState)
    self.test_previous_state = requestState.state
    super
  end
end

describe Platform::MasterMessageEventData do
  let (:time_now) {Utils::Time.current}
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
  let (:api) {
    api = TestPlatformApi.new
    api.mock_answer = suGet

    api.forceGet
    api
  }
  let(:masterMessageBackground) { Platform::BG_MasterMessageEventController.new(api) }
  let(:masterMessageForeground) {TestFGMasterMessageEventController.new(api) }
  let(:eventData) { Platform::MasterMessageEventData.new(masterMessage)}
  before do
    masterMessageBackground
    masterMessageForeground
  end

  it "should obey the protocol all the way through" do
    # MasterMessage Event has been set up with a masterMessage's message to be displayed.
    masterMessage.onDisplay(Utils::Time.current)
    api.bgEvents.postEvent("MasterMessage", eventData)

    api.bgEvents.roll()
    expect(eventData.state).to eq(Platform::RequestConstants::S_INQUIRE_START)


    # Foreground Thread
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::RequestConstants::S_INQUIRE_START)
    expect(eventData.state).to eq(Platform::RequestConstants::S_ANSWER_START)
    expect(masterMessage.displayed).to eq(true)

    # Call from Foreground Thread with resolve info
    masterMessageForeground.resolveGo(eventData)

    # Should have added a Background Event to GO to the URL
    expect(eventData.resolve).to eq(Platform::MasterMessageConstants::R_GO)
    expect(eventData.state).to eq(Platform::RequestConstants::S_REQUEST_START)

    # Background Thread
    api.mock_answer = masterMessageURLMessage
    api.bgEvents.roll()
    expect(eventData.thruUrl).to eq("http://google.com")
    expect(eventData.state).to eq(Platform::RequestConstants::S_NOTIFY_START)

    masterMessageForeground.test_previous_state = nil
    # Foreground Thread
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::RequestConstants::S_NOTIFY_START)
    expect(eventData.thruUrl).to eq("http://google.com")
    expect(eventData.state).to eq(Platform::RequestConstants::S_ACK_START)

    masterMessageForeground.ackOK(eventData)
    expect(eventData.state).to eq(Platform::RequestConstants::S_FINISH)

  end

  it "should obey the protocol all the way through, but with a bad response from the server, should just go to the goUrl" do
    # MasterMessage Event has been set up with a masterMessage's message to be displayed.
    masterMessage.onDisplay(Utils::Time.current)
    api.bgEvents.postEvent("MasterMessage", eventData)

    api.bgEvents.roll()
    expect(eventData.state).to eq(Platform::RequestConstants::S_INQUIRE_START)


    # Foreground Thread
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::RequestConstants::S_INQUIRE_START)
    expect(eventData.state).to eq(Platform::RequestConstants::S_ANSWER_START)
    expect(masterMessage.displayed).to eq(true)

    # Call from Foreground Thread with resolve info
    masterMessageForeground.resolveGo(eventData)

    # Should have added a Background Event to GO to the URL
    expect(eventData.resolve).to eq(Platform::MasterMessageConstants::R_GO)
    expect(eventData.state).to eq(Platform::RequestConstants::S_REQUEST_START)

    # Background Thread
    api.mock_answer = badResponse
    api.bgEvents.roll()
    expect(eventData.thruUrl).to eq("http://busme.us")
    expect(eventData.state).to eq(Platform::RequestConstants::S_NOTIFY_START)

    masterMessageForeground.test_previous_state = nil
    # Foreground Thread
    api.uiEvents.roll()
    expect(masterMessageForeground.test_previous_state).to eq(Platform::RequestConstants::S_NOTIFY_START)
    expect(eventData.thruUrl).to eq("http://busme.us")
    expect(eventData.state).to eq(Platform::RequestConstants::S_ACK_START)

    masterMessageForeground.ackOK(eventData)
    expect(eventData.state).to eq(Platform::RequestConstants::S_FINISH)

  end

end