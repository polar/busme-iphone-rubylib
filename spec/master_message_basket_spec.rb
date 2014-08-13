require "spec_helper"
require "test_master_message_controller"

describe Platform::MasterMessageBasket do

  let(:time_now) { Time.now }
  let(:controller) { TestMasterMessageController.new }
  let(:store) { Platform::MasterMessageStore.new }
  let(:basket) { Platform::MasterMessageBasket.new(store, controller) }
  let(:msg1) do
    b = Api::MasterMessage.new("1")
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
  let(:msg1a) do
    b = Api::MasterMessage.new("1")
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
    b = Api::MasterMessage.new("2")
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

  context "with 1 message" do
    it "should store messages" do
      basket.addMasterMessage(msg1)
      expect(store.masterMessages.values).to include(msg1)
    end

    it "should retrieve messages" do
      basket.addMasterMessage(msg1)
      expect(basket.getMasterMessages).to include(msg1)
    end

    it "should remove messages" do
      basket.addMasterMessage(msg1)
      expect(store.masterMessages.values).to include(msg1)
      basket.removeMasterMessage(msg1.id)
      expect(store.masterMessages.values).to_not include(msg1)
    end

    it "should display message on location" do
      now = time_now
      basket.addMasterMessage(msg1)
      basket.onLocationUpdate(location1, now)
      expect(controller.contains?(msg1)).to eq(true)
      now += 10
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg1)
    end

    it "should not display message on location out of range" do
      now = time_now
      basket.addMasterMessage(msg2)
      basket.onLocationUpdate(location2, now)
      expect(controller.contains?(msg1)).to eq(false)
      now += 10
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(nil)
    end

    it "should update version in the store" do
      now = time_now
      basket.addMasterMessage(msg1)
      expect(store.masterMessages.values).to include(msg1)
      basket.addMasterMessage(msg1a)
      expect(store.masterMessages.values).to_not include(msg1)
      expect(store.masterMessages.values).to include(msg1a)
    end

    context "controller interaction" do
      it "should only display message once on 2 locations after remind Time when not reminded" do
        now = time_now
        basket.addMasterMessage(msg1)
        basket.onLocationUpdate(location1, now)
        expect(controller.contains?(msg1)).to eq(true)
        now += 10
        controller.roll(now)
        expect(controller.test_displayed_master_message).to eq(msg1)
        now += 10
        controller.dismissCurrentMasterMessage(false, now)
        expect(controller.test_displayed_master_message).to eq(nil)
        expect(msg1.seen).to eq(true)
        expect(msg1.lastSeen).to eq(now)
        expect(msg1.displayed).to eq(false)
        expect(msg1.remindTime).to eq(nil)
        now += msg1.remindPeriod + 1
        basket.onLocationUpdate(location2, now)
        now += 10
        controller.roll(now)
        expect(controller.test_displayed_master_message).to eq(nil)
      end

      it "should display message on 2 locations after remind Time" do
        now = time_now
        basket.addMasterMessage(msg1)
        basket.onLocationUpdate(location1, now)
        expect(controller.contains?(msg1)).to eq(true)
        now += 10
        controller.roll(now)
        expect(controller.test_displayed_master_message).to eq(msg1)
        now += 10
        controller.dismissCurrentMasterMessage(true, now)
        expect(msg1.seen).to eq(true)
        expect(msg1.lastSeen).to eq(now)
        expect(msg1.displayed).to eq(false)
        expect(msg1.remindTime).to eq(now + msg1.remindPeriod)
        now = msg1.remindTime
        basket.onLocationUpdate(location2, now)
        now += 10
        controller.roll(now)
        expect(controller.test_displayed_master_message).to eq(msg1)

      end
    end
  end

  context "with 2 messages" do
    it "should only display one message" do
      now = time_now
      basket.addMasterMessage(msg1)
      basket.addMasterMessage(msg2)
      basket.onLocationUpdate(location2, now)
      expect(controller.contains?(msg1)).to eq(true)
      expect(controller.contains?(msg2)).to eq(false)
      now += 10
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg1)
    end

    it "should only display both messages in the right priority" do
      now = time_now
      basket.addMasterMessage(msg1)
      basket.addMasterMessage(msg2)
      basket.onLocationUpdate(location1, now)
      expect(controller.contains?(msg1)).to eq(true)
      expect(controller.contains?(msg2)).to eq(true)
      now += 10
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg2)
      now += 10
      controller.dismissCurrentMasterMessage(false, now)
      now += 10
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg1)
    end

  end

end