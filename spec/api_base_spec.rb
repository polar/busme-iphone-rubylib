require "spec_helper"

describe Api::APIBase, "Http" do
  let(:api) {
    Api::APIBase.new
  }

  it "should get a url" do
    httpEntity = api.openURL("http://busme.us")
    expect(httpEntity).not_to eq(nil)
  end
end