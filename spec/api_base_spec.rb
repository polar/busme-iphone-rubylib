require "spec_helper"

describe Api::ApiBase, "Http" do
  before do
    @api = Api::ApiBase.new
  end

  it "should get a url" do
    httpEntity = @api.openURL("http://busme.us")
    expect(httpEntity).not_to eq(nil)
  end
end