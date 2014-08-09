require "spec_helper"

describe Platform::JourneyStore do
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
  let(:store) {
    Platform::JourneyStore.new
  }

  it "should store pattern" do
    store.storePattern(pattern)
    expect(store.patterns.values).to include(pattern)
    expect(store.containsPattern?(pattern.id)).to eq(true)
  end
  it "should store route" do
    store.storeJourney(route)
    expect(store.journeys.values).to include(route)
    expect(store.containsJourney?(route.id)).to eq(true)
  end
  it "should store journey" do
    store.storeJourney(journey)
    expect(store.journeys.values).to include(journey)
    expect(store.containsJourney?(journey.id)).to eq(true)
  end

  context "all together" do
    it "should have pattern associated" do
      store.storePattern(pattern)
      store.storeJourney(route)
      store.storeJourney(journey)

      expect(route.patternids).to include(pattern.id)
      expect(journey.patternid).to eq(pattern.id)

      expect(route.getJourneyPattern(pattern.id)).to eq(pattern)
      expect(journey.getJourneyPattern(pattern.id)).to eq(pattern)
    end

    it "should preSserialize and postSerialize" do
      store.storePattern(pattern)
      store.storeJourney(route)
      store.storeJourney(journey)

      store.preSerialize
      s = YAML::dump(store)
      store.postSerialize(nil)

      expect(route.patternids).to include(pattern.id)
      expect(journey.patternid).to eq(pattern.id)

      expect(route.getJourneyPattern(pattern.id)).to eq(pattern)
      expect(journey.getJourneyPattern(pattern.id)).to eq(pattern)
    end

    it "should serialize back"         do
      store.storePattern(pattern)
      store.storeJourney(route)
      store.storeJourney(journey)

      store.preSerialize
      s = YAML::dump(store)
      store.postSerialize(nil)

      expect(route.patternids).to include(pattern.id)
      expect(journey.patternid).to eq(pattern.id)

      expect(route.getJourneyPattern(pattern.id)).to eq(pattern)
      expect(journey.getJourneyPattern(pattern.id)).to eq(pattern)

      store1 = YAML::load(s)
      store1.postSerialize(nil)

      r = store1.getJourney(route.id)
      j = store1.getJourney(journey.id)
      p = store1.getPattern(pattern.id)

      expect(r.patternids).to include(pattern.id)
      expect(j.patternid).to eq(pattern.id)

      expect(r.getJourneyPattern(pattern.id)).to eq(p)
      expect(j.getJourneyPattern(pattern.id)).to eq(p)
    end
  end

end