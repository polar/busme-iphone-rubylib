require "spec_helper"

describe Api::JourneyPattern do
  let(:jp_spec) {
    "<P id='12311' version='323423'><JPs><JP lat='54.30' lon='-73.40'/><JP lat='54.31' lon='-73.41'/></JPs></P>"
  }
  let(:pattern) {
    doc = REXML::Document.new(jp_spec)
    tag = Api::Tag.new(doc.root)
    jp = Api::JourneyPattern.new()
    jp.loadParsedXML(tag)
    jp
  }

  it "should parse a JourneyPattern" do
    expect(pattern.path).not_to be(nil)
    expect(pattern.id).to eq("12311")
    expect(pattern.path[0].longitudeE6).to eq(-73400000)
    expect(pattern.path[0].latitudeE6).to eq(54300000)
    expect(pattern.path[1].longitudeE6).to eq(-73410000)
    expect(pattern.path[1].latitudeE6).to eq(54310000)
    expect(pattern.distance).to be_within(0.001).of(4223.708)
  end
end