require "spec_helper"
require "test_master_message_controller"

describe Platform::MasterMessageController do

  let(:time_now)  { Utils::Time.current }
  let(:controller) { TestMasterMessageController.new(nil) }
  let(:msg1) do
    b = Api::MasterMessage.new("1")
    b.expiryTime = time_now + 24 * 60 * 60
    b.remindable = true
    b.remindPeriod = 10
    b.priority = 10
    b
  end
  let(:msg2) do
    b = Api::MasterMessage.new("2")
    b.expiryTime = time_now + 24 * 60 * 60
    b.priority = 11
    b
  end

  context "with one master message" do
    it "should add master message 1" do
      now = time_now
      controller.addMasterMessage(msg1)
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg1)
      expect(msg1.seen).to eq(true)
      expect(msg1.displayed).to eq(true)
      expect(msg1.lastSeen).to be_within(1).of(now)
    end

    it "should add master message 1 and remove it and have the remindTime set" do
      now = time_now
      controller.addMasterMessage(msg1)
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg1)
      expect(msg1.seen).to eq(true)
      expect(msg1.displayed).to eq(true)
      expect(msg1.lastSeen).to be_within(1).of(now)
      now += 5
      controller.dismissCurrentMasterMessage(true, now)
      expect(msg1.seen).to eq(true)
      expect(msg1.displayed).to eq(false)
      expect(msg1.lastSeen).to be_within(1).of(now)
      expect(msg1.remindTime).to eq(now + msg1.remindPeriod)
    end

    it "should expire master message 1" do
      now = time_now
      controller.addMasterMessage(msg1)
      now = msg1.expiryTime + 1
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(nil)
    end

    it "should add master message 2 and remove it and not have the remindTime set" do
      now = time_now
      controller.addMasterMessage(msg2)
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg2)
      expect(msg2.seen).to eq(true)
      expect(msg2.displayed).to eq(true)
      expect(msg2.lastSeen).to be_within(1).of(now)
      now += 5
      controller.dismissCurrentMasterMessage(false, now)
      expect(msg2.seen).to eq(true)
      expect(msg2.displayed).to eq(false)
      expect(msg2.lastSeen).to be_within(1).of(now)
      expect(msg2.remindTime).to eq(nil)
    end
  end

  context "with 2 messages" do
    it "should add 2 messages and show the hire priority, then the lower" do
      now = time_now
      controller.addMasterMessage(msg1)
      controller.addMasterMessage(msg2)
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg2)
      now += 5
      controller.dismissCurrentMasterMessage(false, now)
      expect(controller.currentMasterMessage).to eq(nil)
      now += 1
      controller.roll(now)
      expect(controller.test_displayed_master_message).to eq(msg1)
    end
  end
end