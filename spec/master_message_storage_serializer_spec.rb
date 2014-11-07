require "spec_helper"
require "test_api"

def deleteFiles
  File.delete(File.join("/", "tmp", "testFile"))
rescue
end

describe Platform::MasterMessageStore do
  let(:api) { TestApi.new }
  let(:time_now) { Utils::Time.current }
  let(:store) { Platform::MasterMessageStore.new }
  let(:externalStorageController) { Platform::ExternalStorageController.new(api: api)}
  let(:storageSerializerController) {Platform::StorageSerializerController.new(api, externalStorageController)}
  let(:masterMessage1) do
    m = Api::MasterMessage.new("1")
    m.point = Integration::GeoPoint.new(53.0 * 1E6, -74.0 * 1E6)
    m.radius = 2000
    m.remindable = true
    m.remindPeriod = 10
    m.expiryTime = time_now + (24 * 60 * 60) * 1
    m.priority = 10
    m
  end
  let(:masterMessage2) do
    m = Api::MasterMessage.new("2")
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

  it "should a store a masterMessage" do
    store.addMasterMessage(masterMessage1)
    result = storageSerializerController.cacheStorage(store, "testFile", api)
    expect(result).to eq(true)
    store1 = storageSerializerController.retrieveStorage("testFile", api)
    expect(store1.class).to be(Platform::MasterMessageStore)
    expect(store1.masterMessages["1"].id).to eq(masterMessage1.id)
    expect(store1.masterMessages["1"].seen).to eq(masterMessage1.seen)
    expect(store1.masterMessages["1"].loaded).to eq(masterMessage1.loaded)
    expect(store1.masterMessages["1"].point.latitude).to eq(masterMessage1.point.latitude)
    expect(store1.masterMessages["1"].point.longitude).to eq(masterMessage1.point.longitude)
    expect(store1.masterMessages["1"].radius).to eq(masterMessage1.radius)
    expect(store1.masterMessages["1"].expiryTime).to eq(masterMessage1.expiryTime)
    expect(store1.masterMessages["1"].priority).to eq(masterMessage1.priority)
    expect(store1.masterMessages["1"].content).to eq(masterMessage1.content)
    expect(store1.masterMessages["1"].title).to eq(masterMessage1.title)
  end

  it "should a store more than one masterMessage" do
    store.addMasterMessage(masterMessage1)
    store.addMasterMessage(masterMessage2)
    result = storageSerializerController.cacheStorage(store, "testFile", api)
    expect(result).to eq(true)
    store1 = storageSerializerController.retrieveStorage("testFile", api)
    expect(store1.class).to be(Platform::MasterMessageStore)
    expect(store1.masterMessages["1"].id).to eq(masterMessage1.id)
    expect(store1.masterMessages["1"].seen).to eq(masterMessage1.seen)
    expect(store1.masterMessages["1"].loaded).to eq(masterMessage1.loaded)
    expect(store1.masterMessages["1"].point.latitude).to eq(masterMessage1.point.latitude)
    expect(store1.masterMessages["1"].point.longitude).to eq(masterMessage1.point.longitude)
    expect(store1.masterMessages["1"].radius).to eq(masterMessage1.radius)
    expect(store1.masterMessages["1"].expiryTime).to eq(masterMessage1.expiryTime)
    expect(store1.masterMessages["1"].priority).to eq(masterMessage1.priority)
    expect(store1.masterMessages["1"].content).to eq(masterMessage1.content)
    expect(store1.masterMessages["1"].title).to eq(masterMessage1.title)

    expect(store1.masterMessages["2"].id).to eq(masterMessage2.id)
    expect(store1.masterMessages["2"].seen).to eq(masterMessage2.seen)
    expect(store1.masterMessages["2"].loaded).to eq(masterMessage2.loaded)
    expect(store1.masterMessages["2"].point.latitude).to eq(masterMessage2.point.latitude)
    expect(store1.masterMessages["2"].point.longitude).to eq(masterMessage2.point.longitude)
    expect(store1.masterMessages["2"].radius).to eq(masterMessage2.radius)
    expect(store1.masterMessages["2"].expiryTime).to eq(masterMessage2.expiryTime)
    expect(store1.masterMessages["2"].priority).to eq(masterMessage2.priority)
    expect(store1.masterMessages["2"].content).to eq(masterMessage2.content)
    expect(store1.masterMessages["2"].title).to eq(masterMessage2.title)
  end

end