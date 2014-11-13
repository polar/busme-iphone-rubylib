require 'spec_helper'
require 'test_platform_api'

class TestFGMarkerPresentationController < Platform::FG_MarkerPresentationEventController

  attr_accessor :testDisplayMarker
  attr_accessor :testDismissMarker

  def presentMarker(eventData)
    self.testDisplayMarker = eventData.marker_info
  end

  def abandonMarker(eventData)
    self.testDismissMarker = eventData.marker_info
  end
end

describe Platform::FG_MarkerPresentationEventController do
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
    controller.fgMarkerPresentationEventController = TestFGMarkerPresentationController.new(api)
    controller
  }
  let(:fgMarkerPresentationController) {
    masterController.fgMarkerPresentationEventController
  }
  before do
    api.mock_answer = suGet
    masterController.api.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    masterController.api.bgEvents.roll
    expect(api.ready).to be(true)
  end

  it "should update and present markers to the UI and then remove it after time." do
    masterController.api.mock_answer = response

    masterController.api.bgEvents.postEvent("Update", Platform::UpdateEventData.new)
    masterController.api.bgEvents.roll
    masterController.api.uiEvents.rollAll
    evd = Platform::LocationEventData.new(Platform::Location.new("test", -73.0, 53.0))
    masterController.api.bgEvents.postEvent("LocationUpdate", evd)
    masterController.api.bgEvents.rollAll

    # We will periodically poll the markerPresentationController for new markers
    # or dismissal of old markers.
    masterController.markerPresentationController.roll(time_now)
    masterController.api.uiEvents.rollAll
    info = fgMarkerPresentationController.testDisplayMarker
    expect(info).to_not eq(nil)

    # Should dismiss this marker past its time.
    masterController.markerPresentationController.roll(info.expiryTime + 10)
    masterController.api.uiEvents.rollAll
    info = fgMarkerPresentationController.testDismissMarker
    expect(info).to_not eq(nil)
  end
end