require 'spec_helper'
require 'test_platform_api'

class TestFGMasterMessagePresentationController < Platform::FG_MasterMessagePresentationEventController

  attr_accessor :testDisplayMasterMessage
  attr_accessor :testDismissMasterMessage

  def displayMasterMessage(masterMessageInfo)
    self.testDisplayMasterMessage = masterMessageInfo
  end

  def dismissMasterMessage(masterMessageInfo)
    self.testDisplayMasterMessage = nil
    self.testDismissMasterMessage = masterMessageInfo
  end
end

describe Platform::FG_MasterMessagePresentationEventController do
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
    controller.fgMasterMessagePresentationEventController = TestFGMasterMessagePresentationController.new(api)
    controller
  }
  let(:fgMasterMessagePresentationController) {
    masterController.fgMasterMessagePresentationEventController
  }
  before do
    api.mock_answer = suGet
    masterController.api.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    masterController.api.bgEvents.roll
    expect(api.ready).to be(true)
  end

  it "should update and present masterMessages to the UI and then remove it with user dismiss." do
    masterController.api.mock_answer = response

    masterController.api.bgEvents.postEvent("Update", Platform::UpdateEventData.new)
    masterController.api.bgEvents.rollAll

    evd = Platform::LocationEventData.new(Platform::Location.new("test", -73.0, 53.0))
    masterController.api.bgEvents.postEvent("LocationUpdate", evd)
    masterController.api.bgEvents.rollAll

    # We will periodically poll the masterMessagePresentationController for new masterMessages
    # or dismissal of old masterMessages.
    masterController.masterMessageController.roll(time_now)
    masterController.api.uiEvents.rollAll
    info = fgMasterMessagePresentationController.testDisplayMasterMessage
    expect(info).to_not eq(nil)

    # user dismisses the message
    masterController.masterMessageController.dismissCurrentMasterMessage(true, time_now + 20)
    masterController.api.uiEvents.rollAll
    info = fgMasterMessagePresentationController.testDismissMasterMessage
    expect(info).to_not eq(nil)
  end

  it "should dismiss message if it is removed or versioned out" do
    masterController.api.mock_answer = response

    masterController.api.bgEvents.postEvent("Update", Platform::UpdateEventData.new)
    masterController.api.bgEvents.rollAll

    evd = Platform::LocationEventData.new(Platform::Location.new("test", -73.0, 53.0))
    masterController.api.bgEvents.postEvent("LocationUpdate", evd)
    masterController.api.bgEvents.rollAll

    # We will periodically poll the masterMessagePresentationController for new masterMessages
    # or dismissal of old masterMessages.
    masterController.masterMessageController.roll(time_now)
    msg = masterController.masterMessageController.currentMasterMessage
    expect(msg).to_not eq(nil)
    masterController.api.uiEvents.rollAll
    info = fgMasterMessagePresentationController.testDisplayMasterMessage
    expect(info).to_not eq(nil)

    # pretend we have an update which mandates that we get rid of the message.
    masterController.masterMessageController.removeMasterMessage(msg)
    masterController.api.uiEvents.rollAll
    info = fgMasterMessagePresentationController.testDisplayMasterMessage
    expect(info).to eq(nil)
  end
end