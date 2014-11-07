require "spec_helper"
require "test_api"

def deleteFiles
  File.delete(File.join("/", "tmp", "testFile"))
rescue
end


describe Platform::MarkerStore do
  let(:api) { TestApi.new }
  let(:time_now) { Utils::Time.current }
  let(:store) { Platform::MarkerStore.new }
  let(:externalStorageController) { Platform::ExternalStorageController.new(api: api)}
  let(:storageSerializerController) {Platform::StorageSerializerController.new(api, externalStorageController)}
  let(:marker1) do
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
  let(:marker2) do
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

  before do
    externalStorageController.directory = File.join("/","tmp")
    deleteFiles
    store
  end

  it "should a store a marker" do
    store.addMarker(marker1)
    result = storageSerializerController.cacheStorage(store, "testFile", api)
    expect(result).to eq(true)
    store1 = storageSerializerController.retrieveStorage("testFile", api)
    expect(store1.class).to be(Platform::MarkerStore)
    expect(store1.markers["1"].id).to eq(marker1.id)
    expect(store1.markers["1"].seen).to eq(marker1.seen)
    expect(store1.markers["1"].loaded).to eq(marker1.loaded)
    expect(store1.markers["1"].point.latitude).to eq(marker1.point.latitude)
    expect(store1.markers["1"].point.longitude).to eq(marker1.point.longitude)
    expect(store1.markers["1"].radius).to eq(marker1.radius)
    expect(store1.markers["1"].expiryTime).to eq(marker1.expiryTime)
    expect(store1.markers["1"].priority).to eq(marker1.priority)
    expect(store1.markers["1"].title).to eq(marker1.description)
    expect(store1.markers["1"].title).to eq(marker1.description)
  end

  it "should a store more than one marker" do
    store.addMarker(marker1)
    store.addMarker(marker2)
    result = storageSerializerController.cacheStorage(store, "testFile", api)
    expect(result).to eq(true)
    store1 = storageSerializerController.retrieveStorage("testFile", api)
    expect(store1.class).to be(Platform::MarkerStore)
    expect(store1.markers["1"].id).to eq(marker1.id)
    expect(store1.markers["1"].seen).to eq(marker1.seen)
    expect(store1.markers["1"].loaded).to eq(marker1.loaded)
    expect(store1.markers["1"].point.latitude).to eq(marker1.point.latitude)
    expect(store1.markers["1"].point.longitude).to eq(marker1.point.longitude)
    expect(store1.markers["1"].radius).to eq(marker1.radius)
    expect(store1.markers["1"].expiryTime).to eq(marker1.expiryTime)
    expect(store1.markers["1"].priority).to eq(marker1.priority)
    expect(store1.markers["1"].description).to eq(marker1.description)
    expect(store1.markers["1"].title).to eq(marker1.title)

    expect(store1.markers["2"].id).to eq(marker2.id)
    expect(store1.markers["2"].seen).to eq(marker2.seen)
    expect(store1.markers["2"].loaded).to eq(marker2.loaded)
    expect(store1.markers["2"].point.latitude).to eq(marker2.point.latitude)
    expect(store1.markers["2"].point.longitude).to eq(marker2.point.longitude)
    expect(store1.markers["2"].radius).to eq(marker2.radius)
    expect(store1.markers["2"].expiryTime).to eq(marker2.expiryTime)
    expect(store1.markers["2"].priority).to eq(marker2.priority)
    expect(store1.markers["2"].description).to eq(marker2.description)
    expect(store1.markers["2"].title).to eq(marker2.title)
  end
end

