require "spec_helper"
require "test_platform_api"

describe Platform::Guts do

  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:api) {
    api = TestPlatformApi.new
  }
  let (:guts) {
    Platform::Guts.new(api)
  }

  it "should be able to get a new Master" do
    guts.reinitializeAPI(api: api, directory: "/tmp")
    api.mock_answer = suGet
    guts.getMasterApi
    expect(guts.api.buspass.slug).to eq "syracuse-university"
  end

end