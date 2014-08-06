require "spec_helper"

describe Integration::BoundingBoxE6 do

  it "should initialize" do
    bbox = Integration::BoundingBoxE6.new(-74.0 * 1E6, 53.0 * 1E6, -75.0 * 1E6, 54.0 * 1E6)

    expect(bbox.north).to eq(-74.0)
    expect(bbox.east).to eq(53.0)
    expect(bbox.south).to eq(-75.0)
    expect(bbox.west).to eq(54.0)
  end

  it "should assign" do
    bbox = Integration::BoundingBoxE6.new(0,0,0,0)

    bbox.north = -74.0
    bbox.east = 53.0
    bbox.south = -75.0
    bbox.west = 54.0

    expect(bbox.northE6).to eq(-74.0 * 1E6)
    expect(bbox.eastE6).to eq(53.0 * 1E6)
    expect(bbox.southE6).to eq(-75.0 * 1E6)
    expect(bbox.westE6).to eq(54.0 * 1E6)
  end

  it "should serialize" do
    bbox = Integration::BoundingBoxE6.new(-74.0 * 1E6, 53.0 * 1E6, -75.0 * 1E6, 54.0 * 1E6)

    boxs = YAML::dump(bbox)

    bbox2 = YAML::load(boxs)

    expect(bbox2.north).to eq(-74.0)
    expect(bbox2.east).to eq(53.0)
    expect(bbox2.south).to eq(-75.0)
    expect(bbox2.west).to eq(54.0)

    box2s = YAML::dump(bbox2)

    expect(boxs).to eq(box2s)

  end
end