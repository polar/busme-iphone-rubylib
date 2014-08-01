require "spec_helper"

describe Platform::GeoCalc, "getGeoDistance" do
  before do
    @c1 = Platform::Location.new("")
    @c2 = Platform::Location.new("")
  end

  it 'should be the same' do
    expect(Platform::GeoCalc.getGeoDistance(@c1, @c2)).to be_within(0.1).of 0
  end

  it 'should be equal to 1334 km' do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    target = Platform::GeoCalc::FEET_PER_KM * 1334
    expect(Platform::GeoCalc.getGeoDistance(@c1, @c2)).to be_within(0.001 * target).of(target)
  end

  it 'should be equal to 11790 km' do
    @c1.longitude = 94.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = -53.0
    target = Platform::GeoCalc::FEET_PER_KM * 11790
    expect(Platform::GeoCalc.getGeoDistance(@c1, @c2)).to be_within(0.001 * target).of(target)
  end

  it 'should have a path distance equal to both' do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    @c3 = Platform::Location.new("")
    @c3.longitude = 94.0
    @c3.latitude  = -53.0
    target = Platform::GeoCalc::FEET_PER_KM * (1334 + 11790)
    expect(Platform::GeoCalc.pathDistance([@c1,@c2,@c3])).to be_within(0.001 * target).of(target)
  end

  it "midpoint should be on line" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    @c3 = Platform::Location.new("")
    @c3.longitude = 94.0
    @c3.latitude  = 0.00
    expect(Platform::GeoCalc.isOnLine(@c1, @c2, 60, @c2)).to be(true)
  end

  it "should be on path" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    @c3 = Platform::Location.new("")
    @c3.longitude = 94.0
    @c3.latitude  = -53.0
    expect(Platform::GeoCalc.isOnPath([@c1,@c2,@c3], 60, @c2)).to be(true)
  end

  it "should have a CentralAngle of 0" do
    @c1.longitude = 0.00
    @c1.latitude = 0.00
    @c2.longitude = 0.0
    @c2.latitude  = 0.0
    expect(Platform::GeoCalc.getCentralAngle(@c1, @c2)).to eq(0)
  end

  it "should have a longitudinal CentralAngle of 45" do
    @c1.longitude = 0.00
    @c1.latitude = 0.00
    @c2.longitude = 0.0
    @c2.latitude  = 45.0
    expect(Platform::GeoCalc.getCentralAngle(@c1, @c2)).to be_within(0.0001).of(Platform::GeoCalc.to_radians(45))
  end

  it "should have a lateral CentralAngle of 45" do
    @c1.longitude = 45.00
    @c1.latitude = 0.00
    @c2.longitude = 0.0
    @c2.latitude  = 0.0
    expect(Platform::GeoCalc.getCentralAngle(@c1, @c2)).to be_within(0.0001).of(Platform::GeoCalc.to_radians(45))
  end

  it "should have a GeoAngle of 0" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 94.0
    @c2.latitude  = 53.0
    expect(Platform::GeoCalc.getGeoAngle(@c1, @c2)).to eq(0)
  end

  it "should have a GeoAngle of 90" do
    @c1.longitude = 0.00
    @c1.latitude = 1.00
    @c2.longitude = 0.0
    @c2.latitude  = -1.0
    expect(Platform::GeoCalc.getGeoAngle(@c1, @c2)).to eq(0)
  end

  it "should have a Bearing of 90" do
    @c1.longitude = 74.00
    @c1.latitude = 0.00
    @c2.longitude = 94.0
    @c2.latitude  = 0.0
    expect(Platform::GeoCalc.getBearing(@c1, @c2)).to eq(90)
  end

  it "should have a Bearing of 270" do
    @c1.longitude = 74.00
    @c1.latitude = 0.00
    @c2.longitude = 94.0
    @c2.latitude  = 0.0
    expect(Platform::GeoCalc.getBearing(@c2, @c1)).to eq(270)
  end

  it "should have a Bearing of 0" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 74.0
    @c2.latitude  = -53.0
    expect(Platform::GeoCalc.getBearing(@c2, @c1)).to eq(0)
  end

  it "should have a Bearing of 180" do
    @c1.longitude = 74.00
    @c1.latitude = 53.00
    @c2.longitude = 74.0
    @c2.latitude  = -53.0
    expect(Platform::GeoCalc.getBearing(@c1, @c2)).to eq(180)
  end

end
