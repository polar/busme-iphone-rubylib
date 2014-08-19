require "spec_helper"

describe Platform::MasterMessageStore do
  let(:time_now) { Time.now }
  let(:store) { Platform::MasterMessageStore.new }
  let(:msg1) do
    m = Api::MasterMessage.new("1")
    m.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    m.radius = 2000
    m.remindable = true
    m.remindPeriod = 10
    m.expiryTime = time_now + (24 * 60 * 60) * 1
    m.priority = 10
    m
  end
  let(:msg2) do
    m = Api::MasterMessage.new("2")
    m.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    m.radius = 2000
    m.remindable = true
    m.remindPeriod = 10
    m.expiryTime = time_now + (24 * 60 * 60) * 2
    m.priority = 10
    m
  end

  context "one message in store" do

    it "should be stored" do
      now = time_now
      store.addMasterMessage(msg1)
      msg1.onDisplay(now)
      store.clean(now)
      expect(store.masterMessages.keys).to include(msg1.id)
    end

    it "should be retrieved" do
      store.addMasterMessage(msg1)
      expect(store.getMasterMessages).to include(msg1)
    end

    it "should remove a message by object" do
      now = time_now
      store.addMasterMessage(msg1)
      msg1.onDisplay(now)
      store.clean(now)
      store.addMasterMessage(msg1)
      store.removeMasterMessage(msg1)
      expect(store.masterMessages.keys).to_not include(msg1.id)
    end

    it "should remove a message by id" do
      now = time_now
      store.addMasterMessage(msg1)
      msg1.onDisplay(now)
      store.clean(now)
      store.addMasterMessage(msg1)
      store.removeMasterMessage(msg1.id)
      expect(store.masterMessages.keys).to_not include(msg1.id)
    end

    it "should be expired" do
      now = time_now
      store.addMasterMessage(msg1)
      msg1.onDisplay(now)
      store.clean(now)
      expect(store.masterMessages.keys).to include(msg1.id)
      now = msg1.expiryTime + 1
      store.clean(now)
      expect(store.masterMessages).to_not include(msg1)
    end

    it "should be seen after dismiss, and not reminded, but not in the store" do
      now = time_now
      store.addMasterMessage(msg1)
      msg1.onDisplay(now)
      now += 10
      msg1.onDismiss(false, now)
      store.clean(now)
      expect(store.masterMessages.values).to_not include(msg1)
      expect(store.masterMessages.keys).to include(msg1.id)
      expect(store.masterMessages[msg1.id].version).to eq(msg1.version)
      expect(store.masterMessages[msg1.id].expiryTime).to eq(msg1.expiryTime)
      now = msg1.expiryTime + 1
      store.clean(now)
      expect(store.masterMessages.keys).to_not include(msg1.id)
    end

    it "should be seen after dismiss, with reminded, still in the store" do
      now = time_now
      store.addMasterMessage(msg1)
      msg1.onDisplay(now)
      now += 10
      msg1.onDismiss(true, now)
      store.clean(now)
      expect(store.masterMessages.values).to include(msg1)
      expect(msg1.remindTime).to eq(now + msg1.remindPeriod)
    end
  end

  context "serialization" do
    it "should serialize two messages" do
      now = time_now
      store.addMasterMessage(msg1)
      store.addMasterMessage(msg2)
      store.preSerialize(nil, now)
      s = YAML::dump(store)
      store1 = YAML::load(s)
      now += 10
      store1.postSerialize(nil, now)
      expect(store1.masterMessages.keys).to include(msg1.id)
      expect(store1.masterMessages.keys).to include(msg2.id)
    end

    it "should serialize two messages, but get rid of expired ones" do
      now = time_now
      store.addMasterMessage(msg1)
      store.addMasterMessage(msg2)
      store.preSerialize(nil, now)
      s = YAML::dump(store)
      store1 = YAML::load(s)
      now = msg1.expiryTime + 1
      store1.postSerialize(nil, now)
      expect(store1.masterMessages.keys).to_not include(msg1.id)
      expect(store1.masterMessages.keys).to include(msg2.id)
    end
  end

end