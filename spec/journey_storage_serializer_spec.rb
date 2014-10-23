require "spec_helper"
require "test_api"

def deleteFiles
  File.delete(File.join("/", "tmp", "testFile"))
rescue
end

describe Platform::JourneyStore do
  let(:time_now) { Time.now }
  let(:api) { TestApi.new }
  let(:store) {
    Platform::JourneyStore.new
  }
  let(:externalStorageController) { Platform::ExternalStorageController.new(api: api)}
  let(:storageSerializerController) {Platform::StorageSerializerController.new(api, externalStorageController)}
  let(:route) {
    filename = File.join("spec", "test_data", "R_643_9864eb9e615f740526e93f6297e29435_1399939597.xml")
    spec = File.new(filename)
    doc = REXML::Document.new(spec)
    tag = Api::Tag.new(doc.root)
    route = Api::Route.new
    route.loadParsedXML(tag)
    route
  }
  let(:journey) {
    filename = File.join("spec", "test_data", "V_643_968f501b3e02890cffa2a1e1b80bc3ca_1399940355.xml")
    spec = File.new(filename)
    doc = REXML::Document.new(spec)
    tag = Api::Tag.new(doc.root)
    route = Api::Route.new
    route.loadParsedXML(tag)
    route
  }
  let(:pattern) {
    filename = File.join("spec", "test_data", "P_b2d03c4880f6d57b3b4edfa5aa9c9211.xml")
    spec = File.new(filename)
    doc = REXML::Document.new(spec)
    tag = Api::Tag.new(doc.root)
    pattern = Api::JourneyPattern.new
    pattern.loadParsedXML(tag)
    pattern
  }

  before do
    externalStorageController.directory = File.join("/","tmp")
    deleteFiles
    store
    store.storePattern(pattern)
    store.storeJourney(route)
    store.storeJourney(journey)
  end

  context "with serializer" do
    it "should have pattern associated" do
      expect(route.patternids).to include(pattern.id)
      expect(journey.patternid).to eq(pattern.id)

      expect(route.getJourneyPattern(pattern.id)).to eq(pattern)
      expect(journey.getJourneyPattern(pattern.id)).to eq(pattern)
    end

    it "should preSserialize and postSerialize" do
      result = storageSerializerController.cacheStorage(store, "testFile", api)
      expect(result).to eq(true)

      store1 = storageSerializerController.retrieveStorage("testFile", api)

      # post serialize gets run and re-associates the new store to the route
      # so that it can get the patterns.
      r = store1.getJourney(route.id)
      j = store1.getJourney(journey.id)
      p = store1.getPattern(pattern.id)

      expect(j.journeyPatterns[0].id).to eq(pattern.id)
      expect(r.journeyPatterns.map {|x| x.id}).to include(pattern.id)

      expect(r.getJourneyPattern(pattern.id)).to eq(p)
      expect(j.getJourneyPattern(pattern.id)).to eq(p)
    end
  end

end