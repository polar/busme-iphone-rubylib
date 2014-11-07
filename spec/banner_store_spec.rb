require "spec_helper"
require "test_api"

def deleteFiles
  File.delete(File.join("/", "tmp", "testFile"))
rescue
end

describe Platform::BannerStore do
  let(:api) { TestApi.new }
  let(:time_now) { Utils::Time.current }
  let(:store) {Platform::BannerStore.new}
  let(:externalStorageController) { Platform::ExternalStorageController.new(api: api)}
  let(:storageSerializerController) {Platform::StorageSerializerController.new(api, externalStorageController)}
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

  before do
    externalStorageController.directory = File.join("/","tmp")
    deleteFiles
    store
  end

  it "should a store a banner" do
    store.addBanner(banner1)
    result = storageSerializerController.cacheStorage(store, "testFile", api)
    expect(result).to eq(true)
    store1 = storageSerializerController.retrieveStorage("testFile", api)
    expect(store1.class).to be(Platform::BannerStore)
    expect(store1.banners["1"].id).to eq(banner1.id)
    expect(store1.banners["1"].seen).to eq(banner1.seen)
    expect(store1.banners["1"].loaded).to eq(banner1.loaded)
    expect(store1.banners["1"].point.latitude).to eq(banner1.point.latitude)
    expect(store1.banners["1"].point.longitude).to eq(banner1.point.longitude)
    expect(store1.banners["1"].radius).to eq(banner1.radius)
    expect(store1.banners["1"].expiryTime).to eq(banner1.expiryTime)
    expect(store1.banners["1"].frequency).to eq(banner1.frequency)
    expect(store1.banners["1"].priority).to eq(banner1.priority)
    expect(store1.banners["1"].description).to eq(banner1.description)
    expect(store1.banners["1"].title).to eq(banner1.description)
  end

  it "should a store more than one banner" do
    store.addBanner(banner1)
    store.addBanner(banner2)
    result = storageSerializerController.cacheStorage(store, "testFile", api)
    expect(result).to eq(true)
    store1 = storageSerializerController.retrieveStorage("testFile", api)
    expect(store1.class).to be(Platform::BannerStore)
    expect(store1.banners["1"].id).to eq(banner1.id)
    expect(store1.banners["1"].seen).to eq(banner1.seen)
    expect(store1.banners["1"].loaded).to eq(banner1.loaded)
    expect(store1.banners["1"].point.latitude).to eq(banner1.point.latitude)
    expect(store1.banners["1"].point.longitude).to eq(banner1.point.longitude)
    expect(store1.banners["1"].radius).to eq(banner1.radius)
    expect(store1.banners["1"].expiryTime).to eq(banner1.expiryTime)
    expect(store1.banners["1"].frequency).to eq(banner1.frequency)
    expect(store1.banners["1"].priority).to eq(banner1.priority)
    expect(store1.banners["1"].description).to eq(banner1.description)
    expect(store1.banners["1"].title).to eq(banner1.title)

    expect(store1.banners["2"].id).to eq(banner2.id)
    expect(store1.banners["2"].seen).to eq(banner2.seen)
    expect(store1.banners["2"].loaded).to eq(banner2.loaded)
    expect(store1.banners["2"].point.latitude).to eq(banner2.point.latitude)
    expect(store1.banners["2"].point.longitude).to eq(banner2.point.longitude)
    expect(store1.banners["2"].radius).to eq(banner2.radius)
    expect(store1.banners["2"].expiryTime).to eq(banner2.expiryTime)
    expect(store1.banners["2"].frequency).to eq(banner2.frequency)
    expect(store1.banners["2"].priority).to eq(banner2.priority)
    expect(store1.banners["2"].description).to eq(banner2.description)
    expect(store1.banners["2"].title).to eq(banner2.title)
  end
end