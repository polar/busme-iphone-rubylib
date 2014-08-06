require "spec_helper"
require "test_banner_controller"

describe Platform::BannerController do

  let(:now)  { Time.now }
  let(:controller) { TestBannerController.new }
  let(:banner1) do
    b = Api::BannerInfo.new
    b.expiryTime = now + 24 * 60 * 60
    b.frequency = 10
    b.length = 10
    b.priority = 10
    b
  end
  let(:banner2) do
    b = Api::BannerInfo.new
    b.expiryTime = now + 24 * 60 * 60
    b.frequency = 10
    b.length = 10
    b.priority = 11
    b
  end

  it "should add banner" do
    controller.addBanner(banner1)
    controller.roll(false, now)
    expect(controller.test_displayed_banner).to eq(banner1)
    expect(banner1.seen).to eq(true)
    expect(banner1.lastSeen).to be_within(1).of(now)
  end

  it "should add banner and remove banner as time goes on" do
    controller.addBanner(banner1)
    controller.roll(false, now)
    expect(controller.test_displayed_banner).to eq(banner1)
    expect(banner1.seen).to eq(true)
    # Roll past expiryTime of banner
    controller.roll(false, now + banner1.length + 1)
    expect(controller.test_displayed_banner).to eq(nil)
    expect(controller.test_removed_banner).to eq(banner1)
  end

  it "should not display after its expiry time" do
    controller.addBanner(banner1)
    controller.roll(false, banner1.expiryTime + 1)
    expect(banner1.seen).to eq(false)
    expect(controller.test_displayed_banner).to eq(nil)
  end

  it "should show banner and then remove banner after its expiry time" do
    controller.addBanner(banner1)
    controller.roll(false, now)
    expect(controller.test_displayed_banner).to eq(banner1)
    expect(banner1.seen).to eq(true)

    controller.roll(false, banner1.expiryTime + 1)
    expect(controller.test_displayed_banner).to eq(nil)
    expect(controller.test_removed_banner).to eq(banner1)
  end

  context "when banner is already seen and reintroduced to the controller" do
    it "should not redisplay before its frequency is up" do
      banner1.lastSeen = now
      expect(banner1.seen).to eq(true)
      controller.addBanner(banner1)
      controller.roll(false, now + banner1.frequency - 1)
      expect(controller.test_displayed_banner).to eq(nil)
    end

    it "should redisplay after its frequency is up" do
      banner1.lastSeen = now
      expect(banner1.seen).to eq(true)
      controller.addBanner(banner1)
      controller.roll(false, now + banner1.frequency + 1)
      expect(controller.test_displayed_banner).to eq(banner1)
    end
  end

  context "when two messages" do
    it "should display the higher priority message first" do
      controller.addBanner(banner1)
      controller.addBanner(banner2)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(banner2)
    end

    it "should display the higher priority message, but not the second yet" do
      controller.addBanner(banner1)
      controller.addBanner(banner2)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(banner2)
      controller.roll(false, now + banner2.length)
      expect(controller.test_displayed_banner).to eq(banner2)
    end

    it "should display the higher priority message, but the second after the length of the first" do
      controller.addBanner(banner1)
      controller.addBanner(banner2)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(banner2)
      controller.roll(false, now + banner2.length + 1)
      expect(controller.test_displayed_banner).to eq(banner1)
    end
  end

  # TODO Timing implementation and tests
  # Currently, we only use priority if the times are the same, like now.
  # The whole priority queue needs to be worked out better, because it's
  # time dependent using banner.nextTime(now).
end