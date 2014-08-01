require "spec_helper"

describe Api::MasterMessage, "" do
  it "should parse" do
    msg = "<Message expiryTime='1722542336000' id='update0.32.6' remindPeriod='86400' remindable='true' version='1394035274'> <Title>Update 0.32.6 available.</Title> <Content>You have the 0.0.0 of the Busme App for the Android platform.Please update from the Google Play Store.New Feature: Shake to move the Routes List out and back. Some speed improvements for larger systems.</Content> </Message>"
    doc = REXML::Document.new(msg)
    tag = Api::Tag.new(doc.root)
    m = Api::MasterMessage.new()
    m.loadParsedXML(tag)
    expect(m.id).to eq("update0.32.6")
    expect(m.title).to eq("Update 0.32.6 available.")
    expect(m.content).to eq("You have the 0.0.0 of the Busme App for the Android platform.Please update from the Google Play Store.New Feature: Shake to move the Routes List out and back. Some speed improvements for larger systems.")
    expect(m.expiryTime).to eq(Time.at(1722542336000))
    expect(m.remindPeriod).to eq(86400)
    expect(m.version).to eq(1394035274)
    expect(m.remindable).to eq(true)
  end
end