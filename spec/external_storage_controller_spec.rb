require "spec_helper"
require "test_api"

def deleteFiles
  begin
    File.delete(File.join("/", "tmp", "testFile"))
  rescue Exception => boom
  end
  begin
    File.delete(File.join("/", "tmp", "test.file_with-me"))
  rescue Exception => boom
  end
end

describe Platform::ExternalStorageController do
  let (:api) { TestApi.new }
  let (:controller) {
    Platform::ExternalStorageController.new(api)
  }
  let (:data) { "This is Data for the file" }

  before do
    controller.directory = File.new(File.join("/", "tmp"))
    deleteFiles
  end
  after do
    deleteFiles
  end

  it "should write data to a file" do
    controller.writeFile(data, "testFile")
    expect(File.exist?(File.join("/", "tmp", "testFile"))).to eq(true)
  end

  it "should write data to a legal file name" do
    controller.writeFile(data, "test*file with/me")
    expect(File.exist?(File.join("/", "tmp", "test.file_with-me"))).to eq(true)
  end

  it "should retrieve what it wrote" do
    controller.writeFile(data, "testFile")

    readData = controller.readData("testFile")
    expect(readData).to eq(data)
  end
end