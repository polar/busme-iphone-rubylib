require 'spec_helper'
require 'test_platform_api'

class TestFGMasterMessageController < Platform::FGMasterMessageController

  attr_accessor :testDisplayMasterMessage
  attr_accessor :testDismissMasterMessage

  def presentMasterMessage(eventData)
    self.testDisplayMasterMessage = eventData
  end

  def dismissMasterMessage(eventData)
    self.testDismissMasterMessage = eventData
  end
end

describe Platform::FGMasterMessageController do
  let (:time_now) {Utils::Time.current}
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:badResponse) { TestHttpMessage.new(500, "Internal Error", "")}

  let (:api) {
    api = TestPlatformApi.new
    api.mock_answer = suGet
    api
  }
  let (:guts) { Platform::Guts.new(api: api) }
  let (:response) {
    fileName = File.join("spec", "test_data", "SUUpdate.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:syncresponse) {
    fileName = File.join("spec", "test_data", "SUUpdateWithRoutes.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let(:mainController) {
    Platform::MainController.new(api: api, directory: "/tmp")
  }
  let(:masterController) {
    controller = Platform::MasterController.new(api: api, mainController: mainController)
    controller.fgMasterMessageController = TestFGMasterMessageController.new(api)
    controller
  }
  let(:fgMasterMessageController) {
    masterController.fgMasterMessageController
  }
  before do
    api.mock_answer = suGet
    masterController.api.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    masterController.api.bgEvents.roll
    expect(api.ready).to be(true)
  end

  it "should update and present Master Messages to the UI and then remove it after time." do
    masterController.api.mock_answer = response

    masterController.api.bgEvents.postEvent("Update", Platform::UpdateEventData.new)
    masterController.api.bgEvents.rollAll

    evd = Platform::LocationEventData.new(Platform::Location.new("test", -73.0, 53.0))
    masterController.api.bgEvents.postEvent("LocationUpdate", evd)
    masterController.api.bgEvents.rollAll

    # We will periodically poll the MasterMessageController for new MasterMessages
    # or dismissal of old MasterMessages.
    masterController.masterMessageController.roll(time_now)
    masterController.api.uiEvents.rollAll
    info = fgMasterMessageController.testDisplayMasterMessage
    expect(info).to_not eq(nil)

    # Should dismiss this mastermessage past its time.
    masterController.masterMessageController.roll(time_now + 20)
    masterController.api.uiEvents.rollAll
    info = fgMasterMessageController.testDismissMasterMessage
    expect(info).to_not eq(nil)
  end
end