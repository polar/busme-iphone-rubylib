require "spec_helper"

describe Platform::MarkerStore do
  let(:time_now) { Time.now }
  let(:store) { Platform::MarkerStore.new }
  let(:msg1) do
    m = Api::MarkerInfo.new
    m.id = "1"
    m.version = 100
    m.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    m.radius = 2000
    m.remindable = true
    m.remindPeriod = 10
    m.expiryTime = time_now + (24 * 60 * 60) * 1
    m.priority = 10
    m
  end
  let(:msg2) do
    m = Api::MarkerInfo.new
    m.id = "2"
    m.version = 100
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
      store.addMarker(msg1)
      msg1.onDisplay(now)
      store.clean(now)
      expect(store.markers.keys).to include(msg1.id)
    end

    it "should be retrieved" do
      now = time_now
      store.addMarker(msg1)
      expect(store.getMarkers).to include(msg1)
    end

    it "should remove a marker by marker" do
      now = time_now
      store.addMarker(msg1)
      msg1.onDisplay(now)
      store.clean(now)
      expect(store.markers.keys).to include(msg1.id)
      store.removeMarker(msg1)
      expect(store.markers.keys).to_not include(msg1.id)
    end

    it "should remove a marker by id" do
      now = time_now
      store.addMarker(msg1)
      msg1.onDisplay(now)
      store.clean(now)
      expect(store.markers.keys).to include(msg1.id)
      store.removeMarker(msg1.id)
      expect(store.markers.keys).to_not include(msg1.id)
    end

    it "should be expired" do
      now = time_now
      store.addMarker(msg1)
      msg1.onDisplay(now)
      store.clean(now)
      expect(store.markers.keys).to include(msg1.id)
      now = msg1.expiryTime + 1
      store.clean(now)
      expect(store.markers).to_not include(msg1)
    end

    it "should be seen after dismiss, and not reminded, but not in the store" do
      now = time_now
      store.addMarker(msg1)
      msg1.onDisplay(now)
      now += 10
      msg1.onDismiss(false, now)
      store.clean(now)
      expect(store.markers.values).to_not include(msg1)
      expect(store.markers.keys).to include(msg1.id)
      expect(store.markers[msg1.id].version).to eq(msg1.version)
      expect(store.markers[msg1.id].expiryTime).to eq(msg1.expiryTime)
      now = msg1.expiryTime + 1
      store.clean(now)
      expect(store.markers.keys).to_not include(msg1.id)
    end

    it "should be seen after dismiss, with reminded, still in the store" do
      now = time_now
      store.addMarker(msg1)
      msg1.onDisplay(now)
      now += 10
      msg1.onDismiss(true, now)
      store.clean(now)
      expect(store.markers.values).to include(msg1)
      expect(msg1.remindTime).to eq(now + msg1.remindPeriod)
    end
  end

  context "serialization" do
    it "should serialize two markers" do
      now = time_now
      store.addMarker(msg1)
      store.addMarker(msg2)
      store.preSerialize(nil)
      s = YAML::dump(store)
      store1 = YAML::load(s)
      now += 10
      store1.postSerialize(nil)
      expect(store1.markers.keys).to include(msg1.id)
      expect(store1.markers.keys).to include(msg2.id)
    end

    it "should serialize two markers, but get rid of expired ones" do
      now = time_now
      store.addMarker(msg1)
      store.addMarker(msg2)
      store.preSerialize(nil, now)
      s = YAML::dump(store)
      store1 = YAML::load(s)
      now = msg1.expiryTime + 1
      store1.postSerialize(nil, now)
      expect(store1.markers.keys).to_not include(msg1.id)
      expect(store1.markers.keys).to include(msg2.id)
    end
  end

end