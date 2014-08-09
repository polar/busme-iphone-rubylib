require "spec_helper"
require "test_marker_controller"

describe Platform::MarkerRequestProcessor do

  let(:time_now) { Time.now }
  let(:controller) { TestMarkerController.new }
  let(:store) { Platform::MarkerStore.new }
  let(:basket) { Platform::MarkerBasket.new(nil, store, controller) }
  let(:processor) { Platform::MarkerRequestProcessor.new(basket) }
  let(:marker1) {
    lit = "<Marker id='1' version='1'><Content>Hello</Content></Marker>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
    marker = Api::MarkerInfo.new
    marker.loadParsedXML(tag)
    marker
  }
  let(:marker2) {
    lit = "<Marker id='2' version='1'><Content>Hello</Content></Marker>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
    marker = Api::MarkerInfo.new
    marker.loadParsedXML(tag)
    marker
  }
  let(:response) {
    lit = "<Response><Markers>
            <Marker id='1' destroy='1'/>
            <Marker id='2' version='2'><Content>Goodbye</Content></Marker>
            <Marker id='3' version='1'><Content>Voila</Content></Marker>
          </Markers></Response>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
  }

  it "should give the right arguments" do
    basket.addMarker(marker1)
    basket.addMarker(marker2)
    args = processor.getArguments
    expect(args.size).to eq(4)
    args1 = args.take(2)
    if !args1.include? ["marker_ids[]", marker1.id]
      args2 = args1
      args1 = args.drop(2)
    else
      args2 = args.drop(2)
    end
    expect(args1).to include(["marker_ids[]", marker1.id])
    expect(args1).to include(["marker_versions[]", marker1.version.to_s])
    expect(args2).to include(["marker_ids[]", marker2.id])
    expect(args2).to include(["marker_versions[]", marker2.version.to_s])
  end

  it "should handle the response correctly" do
    basket.addMarker(marker1)
    basket.addMarker(marker2)
    processor.onResponse(response)
    expect(store.markers[marker1.id]).to eq(nil)
    expect(store.markers[marker2.id].version).to eq(2)
    expect(store.markers["3"]).to_not eq(nil)
  end

end