require "spec_helper"

describe Api::MasterMessage do

  let(:time_now) { Utils::Time.current }
  let(:expiryTime) { time_now + 600 }
  let(:msg) {
    "<Message expiryTime='#{expiryTime.to_i}'
              id='update0.32.6'
              remindPeriod='86400'
              remindable='true'
              version='1394035274'>
        <Title>Update 0.32.6 available.</Title>
        <Content>You have the 0.0.0 of the Busme App for the Android platform.Please update from the Google Play Store.New Feature: Shake to move the Routes List out and back. Some speed improvements for larger systems.</Content>
    </Message>"
  }
  it "should parse" do
    doc = REXML::Document.new(msg)
    tag = Api::Tag.new(doc.root)
    m = Api::MasterMessage.new()
    m.loadParsedXML(tag)
    expect(m.id).to eq("update0.32.6")
    expect(m.title).to eq("Update 0.32.6 available.")
    expect(m.content).to eq("You have the 0.0.0 of the Busme App for the Android platform.Please update from the Google Play Store.New Feature: Shake to move the Routes List out and back. Some speed improvements for larger systems.")
    expect(m.expiryTime).to be_within(1).of(expiryTime)
    expect(m.remindPeriod).to eq(86400)
    expect(m.version).to eq(1394035274)
    expect(m.remindable).to eq(true)
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