require "spec_helper"

describe Platform::GeoPathUtils, "getGeoDistance" do
  before do
    @c1 = Integration::GeoPoint.new(0,0)
    @c2 = Integration::GeoPoint.new(0,0)
  end

  it 'should be the same' do
    expect(Platform::GeoPathUtils.getGeoDistance(@c1, @c2)).to be_within(0.1).of 0
  end

  it 'should be equal to 1334 km' do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    target = Platform::GeoCalc::FEET_PER_KM * 1334
    expect(Platform::GeoPathUtils.getGeoDistance(@c1, @c2)).to be_within(0.001 * target).of(target)
  end

  it 'should be equal to 11790 km' do
    @c1.longitude = 94.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = -53.0
    target = Platform::GeoCalc::FEET_PER_KM * 11790
    expect(Platform::GeoPathUtils.getGeoDistance(@c1, @c2)).to be_within(0.001 * target).of(target)
  end

  it 'should have a path distance equal to both' do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    @c3 = Integration::GeoPoint.new(-53.0 * 1E6, 94.0 * 1E6)
    target = Platform::GeoPathUtils::FEET_PER_KM * (1334 + 11790)
    expect(Platform::GeoPathUtils.getDistance([@c1,@c2,@c3])).to be_within(0.001 * target).of(target)
  end

  it "midpoint should be on line" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    # from http://www.movable-type.co.uk/scripts/latlong.html
    @c3 = Integration::GeoPoint.new((53 +25/60 + 14/60/60) * 1E6, 84.0 * 1E6)
    expect(Platform::GeoPathUtils.isOnLine(@c1, @c2, 60, @c2)).to be(true)
    expect(Platform::GeoCalc.getBearing(@c1,@c3)).to be_within(0.01).of(86)
    expect(Platform::GeoCalc.getBearing(@c2,@c3)).to be_within(0.01).of(274)
  end

  it "midpoint should be on path" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    # from http://www.movable-type.co.uk/scripts/latlong.html
    @c3 = Integration::GeoPoint.new((53 +25/60 + 14/60/60) * 1E6, 84.0 * 1E6)
    expect(Platform::GeoCalc.isOnPath([@c1,@c2,@c1], 60, @c3)).to be(true)
  end

  it "should have valid bearings and distances on path with midpoint" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    # midpoint
    @c3 = Integration::GeoPoint.new((53 +25/60 + 14/60/60) * 1E6, 84.0 * 1E6)
    points = Platform::GeoPathUtils.whereOnPath([@c1,@c2], @c3, 60)
    expect(points[0].bearing).to be_within(0.01).of(Platform::GeoCalc.getBearing(@c3, @c2))
    expect(points[0].distance).to eq(Platform::GeoCalc.getGeoDistance(@c1, @c3))
  end

  it "should have more placements on a looped path" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    # We use the midpoint, but we go back and forth 4 times.
    @c3 = Integration::GeoPoint.new((53 +25/60 + 14/60/60) * 1E6, 84.0 * 1E6)
    points = Platform::GeoPathUtils.whereOnPath([@c1,@c2,@c1,@c2,@c1], @c3, 60)
    expect(points.length).to eq(4)
    expect(points[0].bearing).to be_within(0.01).of(Platform::GeoCalc.getBearing(@c3, @c2))
    expect(points[1].bearing).to be_within(0.01).of(Platform::GeoCalc.getBearing(@c2, @c3))
    expect(points[2].bearing).to be_within(0.01).of(Platform::GeoCalc.getBearing(@c3, @c2))
    expect(points[3].bearing).to be_within(0.01).of(Platform::GeoCalc.getBearing(@c2, @c3))
    expect(points[0].distance).to eq(Platform::GeoCalc.getGeoDistance(@c1, @c3))
    expect(points[1].distance).to eq(Platform::GeoCalc.getGeoDistance(@c1, @c2) + Platform::GeoCalc.getGeoDistance(@c2, @c3))
    expect(points[2].distance).to eq(Platform::GeoCalc.getGeoDistance(@c1, @c2)*2 + Platform::GeoCalc.getGeoDistance(@c1, @c3))
    expect(points[3].distance).to eq(Platform::GeoCalc.getGeoDistance(@c1, @c2)*3 + Platform::GeoCalc.getGeoDistance(@c2, @c3))
  end

end
