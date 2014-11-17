require "spec_helper"
require 'test_platform_api'
require "test_marker_controller"

describe Platform::MarkerBasket do

  let(:time_now) { Utils::Time.current }
  let(:platform_api) { TestPlatformApi.new }
  let(:controller) { TestMarkerController.new(platform_api) }
  let(:store) { Platform::MarkerStore.new }
  let(:basket) { Platform::MarkerBasket.new(store, controller) }
  let(:msg1) do
    b = Api::MarkerInfo.new
    b.id = "1"
    b.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    b.version = 10000
    b.title = "Title 1"
    b.content = "Content 1"
    b.radius = 2000
    b.expiryTime = time_now + (24 * 60 * 60) * 1
    b.remindable = true
    b.remindPeriod = 10
    b.priority = 10
    b
  end
  let(:msg1_2) do
    b = Api::MarkerInfo.new
    b.id = "1"
    b.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    b.version = 10001
    b.title = "Title 1_2"
    b.content = "Content 1_2"
    b.radius = 2000
    b.expiryTime = time_now + (24 * 60 * 60) * 1
    b.remindable = true
    b.remindPeriod = 10
    b.priority = 10
    b
  end
  let(:msg1a) do
    b = Api::MarkerInfo.new
    b.id = "1a"
    b.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    b.version = 10033
    b.title = "Title 1a"
    b.content = "Content 1a"
    b.radius = 2000
    b.expiryTime = time_now + (24 * 60 * 60) * 1
    b.remindable = true
    b.remindPeriod = 10
    b.priority = 10
    b
  end
  let(:msg2) do
    b = Api::MarkerInfo.new
    b.id = "2"
    b.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    b.version = 3
    b.title = "Title 2"
    b.content = "Content 2"
    b.radius = 1000
    b.expiryTime = time_now + (24 * 60 * 60) * 2
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

  context "with 1 marker" do
    it "should store markers" do
      basket.addMarker(msg1)
      expect(store.markers.values).to include(msg1)
    end

    it "should remove markers" do
      basket.addMarker(msg1)
      expect(store.markers.values).to include(msg1)
      basket.removeMarker(msg1.id)
      expect(store.markers.values).to_not include(msg1)
    end

    it "should replace markers by version" do
      basket.addMarker(msg1)
      expect(store.markers.values).to include(msg1)
      basket.addMarker(msg1_2)
      expect(store.markers.values).to_not include(msg1)
      expect(store.markers.values).to include(msg1_2)
    end

    it "should display marker on location" do
      now = time_now
      basket.addMarker(msg1)
      basket.onLocationUpdate(location1, now)
      expect(controller.contains?(msg1)).to eq(true)
      now += 10
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg1)
    end

    it "should not display marker on location out of range" do
      now = time_now
      basket.addMarker(msg2)
      basket.onLocationUpdate(location2, now)
      expect(controller.contains?(msg1)).to eq(false)
      now += 10
      controller.roll(now)
      expect(controller.test_current_markers).to_not include(msg1)
    end

    it "should update version in the store" do
      now = time_now
      basket.addMarker(msg1)
      expect(store.markers.values).to include(msg1)
      basket.addMarker(msg1a)
      expect(store.markers.values).to include(msg1)
      expect(store.markers.values).to include(msg1a)
    end

    context "controller interaction" do
      it "should only display marker once on 2 locations after remind Time when not reminded" do
        now = time_now
        basket.addMarker(msg1)
        basket.onLocationUpdate(location1, now)
        expect(controller.contains?(msg1)).to eq(true)
        now += 10
        controller.roll(now)
        expect(controller.test_current_markers).to include(msg1)
        now += 10
        controller.dismissMarker(msg1, false, now)
        expect(controller.test_current_markers).to_not include(msg1)
        expect(msg1.seen).to eq(true)
        expect(msg1.lastSeen).to eq(now)
        expect(msg1.displayed).to eq(false)
        expect(msg1.remindTime).to eq(nil)
        now += msg1.remindPeriod + 1
        basket.onLocationUpdate(location2, now)
        now += 10
        controller.roll(now)
        expect(controller.test_current_markers).to_not include(msg1)
      end

      it "should display marker on 2 locations after remind Time" do
        now = time_now
        basket.addMarker(msg1)
        basket.onLocationUpdate(location1, now)
        expect(controller.contains?(msg1)).to eq(true)
        now += 10
        controller.roll(now)
        expect(controller.test_current_markers).to include(msg1)
        now += 10
        controller.dismissMarker(msg1, true, now)
        expect(msg1.seen).to eq(true)
        expect(msg1.lastSeen).to eq(now)
        expect(msg1.displayed).to eq(false)
        expect(msg1.remindTime).to eq(now + msg1.remindPeriod)
        now = msg1.remindTime
        basket.onLocationUpdate(location2, now)
        now += 10
        controller.roll(now)
        expect(controller.test_current_markers).to include(msg1)

      end
    end
  end

  context "with 2 markers" do
    it "should only display one marker" do
      now = time_now
      basket.addMarker(msg1)
      basket.addMarker(msg2)
      basket.onLocationUpdate(location2, now)
      expect(controller.contains?(msg1)).to eq(true)
      expect(controller.contains?(msg2)).to eq(false)
      now += 10
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg1)
    end

    it "should only display both markers in the right priority" do
      now = time_now
      basket.addMarker(msg1)
      basket.addMarker(msg2)
      basket.onLocationUpdate(location1, now)
      expect(controller.contains?(msg1)).to eq(true)
      expect(controller.contains?(msg2)).to eq(true)
      now += 10
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg2)
      now += 10
      controller.dismissMarker(msg2, false, now)
      now += 10
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg1)
    end

  end

end