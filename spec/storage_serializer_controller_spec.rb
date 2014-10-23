require "spec_helper"
require "test_api"

def deleteFiles
  begin
    File.delete(File.join("/", "tmp", "testFile"))
  rescue Exception => boom
  end
end

class TestStorage
  include Api::Storage
  attr_accessor :test_data
  attr_accessor :test_obj
  def initialize

  end

  def preSerialize(api)
    self.test_obj = nil
  end
  def postSerialize(api)
    self.test_obj = api
  end
end

describe Platform::StorageSerializerController do
  let (:api) { TestApi.new }
  let (:externalStorageController) {
    Platform::ExternalStorageController.new(api: api)
  }
  let (:test_data) { "This is Data for the file" }
  let (:store) {
    TestStorage.new.tap do |s|
        s.test_data = test_data
        s.test_obj = api
    end
  }
  let (:controller) { Platform::StorageSerializerController.new(api, externalStorageController)}

  before do
    externalStorageController.directory = File.new(File.join("/", "tmp"))
    deleteFiles
  end
  after do
    deleteFiles
  end

  it "should write data to a file" do
    controller.cacheStorage(store, "testFile", api)
    expect(File.exist?(File.join("/", "tmp", "testFile"))).to eq(true)
  end

  it "should call post serialize and restore nil test_object" do
    result = controller.cacheStorage(store, "testFile", api)
    expect(result).to eq(true)
    expect(store.test_obj).to eq(api)
  end

  it "should retrieve what it wrote and run the serializers" do
    result = controller.cacheStorage(store, "testFile", api)
    expect(result).to eq(true)
    store = controller.retrieveStorage("testFile", api)
    expect(store.test_obj).to eq(api)
    expect(store.test_data).to eq(test_data)
  end
end