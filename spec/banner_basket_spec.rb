require "spec_helper"
require "test_banner_controller"

describe Platform::BannerBasket do
  let(:time_now) { Time.now }
  let(:store) { Platform::BannerStore.new }
  let(:controller) { TestBannerController.new(nil) }
  let(:basket) { Platform::BannerBasket.new(store, controller)}
  let(:banner1) do
    b = Api::BannerInfo.new
    b.id = "1"
    b.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    b.radius = 2000
    b.expiryTime = time_now + 24 * 60 * 60
    b.frequency = 10
    b.length = 10
    b.priority = 10
    b
  end
  let(:banner2) do
    b = Api::BannerInfo.new
    b.id = "2"
    b.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    b.radius = 1000
    b.expiryTime = time_now + 24 * 60 * 60
    b.frequency = 10
    b.length = 10
    b.priority = 11
    b
  end
  let(:location1) do
    loc = Platform::Location.new("")
    loc.latitude = 53.0
    loc.longitude = -74.0
    loc
  end
  let(:location2) do
    loc = Platform::Location.new("")
    loc.latitude = 53.003
    loc.longitude = -74.0
    loc
  end

  context "with one stored banner" do
    it "should display banner" do
      now = time_now
      basket.addBanner(banner1)
      basket.onLocationUpdate(location1)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(banner1)
    end

    it "should remove display banner after time" do
      now = time_now
      basket.addBanner(banner1)
      basket.onLocationUpdate(location1)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(banner1)

      controller.roll(false, now + banner1.length + 1)
      expect(controller.test_displayed_banner).to eq(nil)
    end

    it "should remove display banner after time and redisplay" do
      now = time_now
      basket.addBanner(banner1)
      basket.onLocationUpdate(location1, now)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(banner1)

      # Will expire from the display queue
      now += banner1.length + 1
      basket.onLocationUpdate(location1, now)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(nil)

      # Will not get picked up by the basket.
      now += banner1.frequency - 1
      basket.onLocationUpdate(location1, now)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(nil)

      # Will get picked up by the basket and placed on the display queue
      now += 2
      basket.onLocationUpdate(location1, now)
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(banner1)
      expect(banner1.beginSeen).to eq(now)

      # Will get picked up by the basket and may be placed on the display multiple times
      now += banner1.length +  1
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(nil)
      now += banner1.frequency + 1
      basket.onLocationUpdate(location1, now)
      now += 1
      basket.onLocationUpdate(location1, now)
      # but will only be shown once
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(banner1)
      now += banner1.length + 1
      controller.roll(false, now)
      expect(controller.test_displayed_banner).to eq(nil)
    end

    context "with two stored banners" do

      it "should display the higher priority" do
        now = time_now
        basket.addBanner(banner1)
        basket.addBanner(banner2)
        basket.onLocationUpdate(location1, now)
        controller.roll(false, now)
        expect(controller.test_displayed_banner).to eq(banner2)
      end

      it "should display the higher priority then the lower priority" do
        now = time_now
        basket.addBanner(banner1)
        basket.addBanner(banner2)
        basket.onLocationUpdate(location1, now)
        controller.roll(false, now)
        expect(controller.test_displayed_banner).to eq(banner2)

        now += banner2.length + 1
        basket.onLocationUpdate(location1, now)
        controller.roll(false, now)
        expect(controller.test_displayed_banner).to eq(banner1)
      end

      it "should display the outer one" do
        now = time_now
        basket.addBanner(banner1)
        basket.addBanner(banner2)
        basket.onLocationUpdate(location2, now)
        controller.roll(false, now)
        expect(controller.test_displayed_banner).to eq(banner1)
      end

      it "should display the outer one, then the inner one" do
        now = time_now
        basket.addBanner(banner1)
        basket.addBanner(banner2)
        basket.onLocationUpdate(location2, now)
        controller.roll(false, now)
        expect(controller.test_displayed_banner).to eq(banner1)
        now += banner1.length + 1
        basket.onLocationUpdate(location1, now)
        controller.roll(false, now)
        expect(controller.test_displayed_banner).to eq(banner2)
      end
    end
  end
end