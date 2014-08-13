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
  let(:eventData) { Platform::BannerEventData.new(banner)}
  before do
    bannerBackground
    bannerForeground
  end

  it "a background click should call for a foreground clicked." do
    api.uiEvents.postEvent("BannerEvent", eventData)
    api.uiEvents.roll()
    expect(bannerForeground.test_state).to eq(Platform::BannerEventData::S_PRESENT)
    expect(eventData.state).to eq(Platform::BannerEventData::S_CLICK)
    httpClient.mock_answer = bannerURLMessage
    api.bgEvents.roll()
    expect(eventData.thruUrl).to eq("http://google.com")
    api.uiEvents.roll()
    expect(bannerForeground.test_state).to eq(Platform::BannerEventData::S_CLICKED)
    expect(bannerForeground.test_url).to eq("http://google.com")
  end

end