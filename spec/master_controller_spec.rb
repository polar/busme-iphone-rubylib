require "spec_helper"
require "test_http_client"
require 'test_foreground'

class TestMainController < Platform::MainController
  attr_accessor :switched
  attr_accessor :switched_master
  attr_accessor :saveAsDefault
  def switchMaster(master, api, saveAdDefault)
    self.switched_master = master
    self.switched = api
    self.saveAsDefault = saveAsDefault
  end
end


describe Platform::MasterController do
  let(:httpClient) {
    Testlib::MyHttpClient.new(TestHttpClient.new)
  }
  let(:api) {
    Api::BuspassAPI.new(httpClient, "syracuse-university", "http://nothing", "Platform", "0.0.0")
  }
  let(:mainController) {
    TestMainController.new
  }
  let(:masterController) {
    Platform::MasterController.new(api: api, mainController: mainController)
  }
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:testForeground) {
    TestForeground.new(masterController.api, ["Master:Init:return"])
  }
  before {
    mainController
    masterController
    testForeground
  }

  it "should do a get" do
    httpClient.mock_answer = suGet
    masterController.api.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    masterController.api.bgEvents.roll
    expect(api.ready).to be(true)
    # Since the version is nothing, we should get an upgrade message
    expect(api.buspass.initialMessages).to_not be(nil)
    expect(api.buspass.initialMessages[0].title).to match(/Update/)
    expect(api.buspass.initialMessages[0].content).to match(/You have the 0.0.0/)
  end

  it "should return a UI event after a get" do
    httpClient.mock_answer = suGet
    masterController.api.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    masterController.api.bgEvents.roll
    event = masterController.api.uiEvents.peek
    expect(event.eventName).to eq("Master:Init:return")
    masterController.api.uiEvents.roll
    expect(testForeground.lastEvent.eventData.return).to be_a(Api::BuspassAPI)
  end
end