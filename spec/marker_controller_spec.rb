require "spec_helper"
require "test_marker_controller"

describe Platform::MarkerPresentationController do

  let(:time_now)  { Utils::Time.current }
  let(:controller) { TestMarkerController.new }
  let(:msg1) do
    b = Api::MarkerInfo.new
    b.id = "1"
    b.version = 100
    b.expiryTime = time_now + 24 * 60 * 60
    b.remindable = true
    b.remindPeriod = 10
    b.priority = 10
    b
  end
  let(:msg2) do
    b = Api::MarkerInfo.new
    b.id = "2"
    b.version = 100
    b.expiryTime = time_now + 24 * 60 * 60
    b.priority = 11
    b
  end

  context "with one marker" do
    it "should add maker 1" do
      now = time_now
      controller.addMarker(msg1)
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg1)
      expect(msg1.seen).to eq(true)
      expect(msg1.displayed).to eq(true)
      expect(msg1.lastSeen).to be_within(1).of(now)
    end

    it "should add markers 1 and remove it and have the remindTime set" do
      now = time_now
      controller.addMarker(msg1)
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg1)
      expect(msg1.seen).to eq(true)
      expect(msg1.displayed).to eq(true)
      expect(msg1.lastSeen).to be_within(1).of(now)
      now += 5
      controller.dismissMarker(msg1, true, now)
      expect(controller.test_current_markers).to_not include(msg1)
      expect(msg1.seen).to eq(true)
      expect(msg1.displayed).to eq(false)
      expect(msg1.lastSeen).to be_within(1).of(now)
      expect(msg1.remindTime).to eq(now + msg1.remindPeriod)
    end

    it "should expire master message 1" do
      now = time_now
      controller.addMarker(msg1)
      now = msg1.expiryTime + 1
      controller.roll(now)
      expect(controller.test_current_markers).to_not include(msg1)
    end

    it "should add marker 2 and remove it and not have the remindTime set" do
      now = time_now
      controller.addMarker(msg2)
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg2)
      expect(msg2.seen).to eq(true)
      expect(msg2.displayed).to eq(true)
      expect(msg2.lastSeen).to be_within(1).of(now)
      now += 5
      controller.dismissMarker(msg2, false, now)
      expect(msg2.seen).to eq(true)
      expect(msg2.displayed).to eq(false)
      expect(msg2.lastSeen).to be_within(1).of(now)
      expect(msg2.remindTime).to eq(nil)
      expect(controller.test_current_markers).to_not include(msg2)
    end
  end

  context "with 2 markers" do
    it "should add 2 messages and show only the hire priority, then the lower" do
      now = time_now
      controller.markerPresentLimit = 1
      controller.addMarker(msg1)
      controller.addMarker(msg2)
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg2)
      expect(controller.test_current_markers).to_not include(msg1)
      now += 5
      controller.dismissMarker(msg2, false, now)
      expect(controller.test_current_markers).to_not include(msg2)
      now += 1
      controller.roll(now)
      expect(controller.test_current_markers).to include(msg1)
    end
  end
end