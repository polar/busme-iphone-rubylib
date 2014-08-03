require "spec_helper"

describe Api::JourneyPattern do
  before do
    @jplit = "<P id='12311' version='323423'><JPs><JP lat='54.30' lon='-73.40'/><JP lat='54.31' lon='-73.41'/></JPs></P>"
    doc = REXML::Document.new(@jplit)
    @jptag = Api::Tag.new(doc.root)
  end

  it "should parse a JourneyPattern" do
    jp = Api::JourneyPattern.new()
    jp.loadParsedXML(@jptag)
    expect(jp.path).not_to be(nil)
    expect(jp.id).to eq("12311")
    expect(jp.path[0].longitudeE6).to eq(-73400000)
    expect(jp.path[0].latitudeE6).to eq(54300000)
    expect(jp.path[1].longitudeE6).to eq(-73410000)
    expect(jp.path[1].latitudeE6).to eq(54310000)
    expect(jp.distance).to be_within(0.001).of(4223.708)
  end
end