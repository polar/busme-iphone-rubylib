require "spec_helper"

describe Platform::PathUtils do
  before do
    @c1 = Integration::Point.new(0,0)
    @c2 = Integration::Point.new(0,0)
  end

  it 'should be the same' do
    expect(Platform::PathUtils.distance(@c1, @c2)).to be_within(0.1).of 0
  end

  it 'should be equal to 1334 km' do
    @c1.y = 74.00
    @c1.x = 53.00
    @c2.y = 94.0
    @c2.x  = 53.0
    target = 20
    expect(Platform::PathUtils.distance(@c1, @c2)).to be_within(0.001 * target).of(target)
  end

  it 'should be equal to 11790 km' do
    @c1.y = 94.00
    @c1.x = 53.00
    @c2.y = 94.0
    @c2.x  = -53.0
    target = 106
    expect(Platform::PathUtils.distance(@c1, @c2)).to be_within(0.001 * target).of(target)
  end

  it 'should have a path distance equal to both' do
    @c1.y = 74.00
    @c1.x = 53.00
    @c2.y = 94.0
    @c2.x  = 53.0
    @c3 = Integration::Point.new(-53.0, 94.0)
    target = 126
    expect(Platform::PathUtils.pathDistance([@c1,@c2,@c3])).to be_within(0.001 * target).of(target)
  end

  it "midpoint should be on line" do
    @c1.y = 74.00
    @c1.x = 53.00
    @c2.y = 94.0
    @c2.x  = 53.0
    # from http://www.movable-type.co.uk/scripts/latlong.html
    @c3 = Integration::Point.new((53 +25/60 + 14/60/60), 84.0)
    expect(Platform::PathUtils.isOnLine(@c1, @c2, @c3, 2)).to be(true)
  end

  it "midpoint should be on path" do
    @c1.y = 74.00
    @c1.x = 53.00
    @c2.y = 94.0
    @c2.x  = 53.0
    # from http://www.movable-type.co.uk/scripts/latlong.html
    @c3 = Integration::Point.new((53 +25/60 + 14/60/60), 84.0)
    expect(Platform::PathUtils.isOnPath([@c1,@c2,@c1], @c3, 60)).to be(true)
  end


end
