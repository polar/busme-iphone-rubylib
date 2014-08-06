require "spec_helper"

describe Platform::MessageStore do
  let(:time_now) { Time.now }
  let(:store) { Platform::MessageStore.new }
  let(:msg1) do
    m = Api::MasterMessage.new("1")
    m.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    m.radius = 2000
    m.remindable = true
    m.remindPeriod = 10
    m.expiryTime = time_now + 24 * 60 * 60
    m.priority = 10
    m
  end
  let(:msg2) do
    m = Api::MasterMessage.new("2")
    m.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    m.radius = 2000
    m.remindable = true
    m.remindPeriod = 10
    m.expiryTime = time_now + 24 * 60 * 60
    m.priority = 10
    m
  end

  context "one message in store" do

    it "should be seen" do
      store.isNowSeen(msg1)
      expect(store.isSeen(msg1.id)).to eq(true)
    end

    it "should not have message 2" do
      store.isNowSeen(msg1)
      expect(store.isSeen(msg2.id)).to eq(false)
    end
  end

end