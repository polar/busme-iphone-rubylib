require "spec_helper"

describe Api::Tag, "Initial" do
  before do
    @doc = REXML::Document.new("<hi a='hello'><tgs><tg a='1'/><tg a='2'/></tgs>this</hi>")
    @tag = Api::Tag.new(@doc.root)
  end
  it "should have a tag" do
    expect(@tag.text).to eq("this")
  end
  it "should have an attribute" do
    expect(@tag.attributes["a"]).to eq("hello")
  end
  it "should have childNodes" do
    expect(@tag.childNodes).to_not eq(nil)
    expect(@tag.childNodes.size).to eq(1)
    expect(@tag.childNodes[0].childNodes.size).to eq(2)
    expect(@tag.childNodes[0].childNodes[1].name).to eq("tg")
    expect(@tag.childNodes[0].childNodes[1].attributes["a"]).to eq("2")
  end
end