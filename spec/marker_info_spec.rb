require "spec_helper"

describe Api::MarkerInfo do

  let(:time_now) { Time.now }
  let(:expiryTime) { time_now + 600 }
  let(:msg) {
    "<Marker expiryTime='#{expiryTime.to_i}'
              id='1'
              remindPeriod='86400'
              remindable='true'
              lat='53.0'
              lon='-74.0'
              goUrl='http://google.com'
              iconUrl='http://imgur.com/2343'
              version='1394035274'>
        <Title>CAFE</Title>
        <GoLabel>GO!</GoLabel>
        <Content>A cafe for you</Content>
    </Marker>"
  }
  it "should parse" do
    doc = REXML::Document.new(msg)
    tag = Api::Tag.new(doc.root)
    m = Api::MarkerInfo.new
    m.loadParsedXML(tag)
    expect(m.id).to eq("1")
    expect(m.title).to eq("CAFE")
    expect(m.goUrl).to eq("http://google.com")
    expect(m.iconUrl).to eq("http://imgur.com/2343")
    expect(m.content).to eq("A cafe for you")
    expect(m.expiryTime).to be_within(1).of(expiryTime)
    expect(m.remindPeriod).to eq(86400)
    expect(m.version).to eq(1394035274)
    expect(m.remindable).to eq(true)
    expect(m.point).to_not eq(nil)
    expect(m.point.latitude).to eq(53.0)
    expect(m.point.longitude).to eq(-74.0)
  end

  it "should be seen after displayed" do
    doc = REXML::Document.new(msg)
    tag = Api::Tag.new(doc.root)
    m = Api::MasterMessage.new()
    m.loadParsedXML(tag)

    now = time_now + 10
    m.onDisplay(now)
    expect(m.seen).to eq(true)
    expect(m.lastSeen).to eq(now)
    expect(m.displayed).to eq(true)
  end

  it "should be reminded after dismissed" do
    doc = REXML::Document.new(msg)
    tag = Api::Tag.new(doc.root)
    m = Api::MasterMessage.new()
    m.loadParsedXML(tag)

    now = time_now + 10
    m.onDisplay(now)

    now += 10
    m.onDismiss(true, now)
    expect(m.seen).to eq(true)
    expect(m.lastSeen).to eq(now)
    expect(m.displayed).to eq(false)
    expect(m.remindTime).to eq(now + m.remindPeriod)

  end

  it "should not be reminded after dismissed" do
    doc = REXML::Document.new(msg)
    tag = Api::Tag.new(doc.root)
    m = Api::MasterMessage.new()
    m.loadParsedXML(tag)

    now = time_now + 10
    m.onDisplay(now)

    now += 10
    m.onDismiss(false, now)
    expect(m.seen).to eq(true)
    expect(m.lastSeen).to eq(now)
    expect(m.displayed).to eq(false)
    expect(m.remindTime).to eq(nil)
  end
end