require "spec_helper"

describe Integration::Rect do

  it "should have positive height" do
    rect = Integration::Rect.new(-1,1,1,-1)
    expect(rect.height).to eq(2)
    expect(rect.width).to eq(2)
  end

  it "should have correct area" do
    rect = Integration::Rect.new(-1,1,1,-1)
    expect(rect.area).to eq(4)
  end

  it "should have correct center" do
    rect = Integration::Rect.new(-1,1,1,-1)
    center = rect.center
    expect(center.x).to eq(0)
    expect(center.y).to eq(0)
  end

  it "should find point" do
    rect = Integration::Rect.new(-1,1,1,-1)
    expect(rect.containsXY(0,0)).to eq(true)
  end

  it "should contain l,r,t,b" do
    rect1 = Integration::Rect.new(-2,2,2,-2)
    expect(rect1.contains(-1,1,1,-1)).to eq(true)
  end

  it "should contain other rects and not opposite" do
    rect1 = Integration::Rect.new(-2,2,2,-2)
    rect2 = Integration::Rect.new(-1,1,1,-1)
    expect(rect1.containsRect(rect2)).to eq(true)
    expect(rect2.containsRect(rect1)).to eq(false)
  end
  it "should interset other rects and not opposite" do
    rect1 = Integration::Rect.new(-2,2,2,-2)
    rect2 = Integration::Rect.new(-1,1,1,-1)
    expect(rect1.intersectRect(rect2)).to eq(true)
    expect(rect2.intersectRect(rect1)).to eq(true)
  end

end