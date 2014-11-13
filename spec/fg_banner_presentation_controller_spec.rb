require 'spec_helper'
require 'test_platform_api'

class TestFGBannerPresentationController < Platform::FG_BannerPresentationEventController

  attr_accessor :testDisplayBanner
  attr_accessor :testDismissBanner

  def displayBanner(bannerInfo)
    self.testDisplayBanner = bannerInfo
  end

  def dismissBanner(bannerInfo)
    self.testDismissBanner = bannerInfo
  end
end

describe Platform::FG_BannerPresentationEventController do
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
    controller.fgBannerPresentationEventController = TestFGBannerPresentationController.new(api)
    controller
  }
  let(:fgBannerPresentationController) {
    masterController.fgBannerPresentationEventController
  }
  before do
    api.mock_answer = suGet
    masterController.api.bgEvents.postEvent("Master:init", Platform::MasterEventData.new())
    masterController.api.bgEvents.roll
    expect(api.ready).to be(true)
  end

  it "should update and present banners to the UI and then remove it after time." do
    masterController.api.mock_answer = response

    masterController.api.bgEvents.postEvent("Update", Platform::UpdateEventData.new)
    masterController.api.bgEvents.roll
    while masterController.api.uiEvents.roll do

    end
    evd = Platform::LocationEventData.new(Platform::Location.new("test", -73.0, 53.0))
    masterController.api.bgEvents.postEvent("LocationUpdate", evd)
    while masterController.api.bgEvents.roll do;end

    # We will periodically poll the bannerPresentationController for new banners
    # or dismissal of old banners.
    masterController.bannerPresentationController.roll(false)
    masterController.api.uiEvents.rollAll
    info = fgBannerPresentationController.testDisplayBanner
    expect(info).to_not eq(nil)

    # Should dismiss this banner past its time.
    masterController.bannerPresentationController.roll(false, time_now + 20)
    masterController.api.uiEvents.rollAll
    info = fgBannerPresentationController.testDismissBanner
    expect(info).to_not eq(nil)
  end
end