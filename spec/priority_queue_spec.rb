require "spec_helper"

describe Utils::PriorityQueue do

  it "should sort well" do
    q = Utils::PriorityQueue.new([4,2,3,1])
    expect(q.peek).to eq(4)
    expect(q.pop).to eq(4)
    expect(q.pop).to eq(3)
    expect(q.pop).to eq(2)
    expect(q.pop).to eq(1)
    expect(q.pop).to eq(nil)
  end

  it "should handle comparitor" do
    q = Utils::PriorityQueue.new([4,2,3,1]) {|lhs,rhs| rhs <=> lhs}
    expect(q.peek).to eq(1)
    expect(q.pop).to eq(1)
    expect(q.pop).to eq(2)
    expect(q.pop).to eq(3)
    expect(q.pop).to eq(4)
    expect(q.pop).to eq(nil)
  end

  it "should handle delete" do
    q = Utils::PriorityQueue.new([4,2,3,1]) {|lhs,rhs| rhs <=> lhs}
    expect(q.delete(3)).to eq(3)
    expect(q.peek).to eq(1)
    expect(q.pop).to eq(1)
    expect(q.pop).to eq(2)
    expect(q.pop).to eq(4)
    expect(q.pop).to eq(nil)
  end

  it "should push well and use poll" do
    q = Utils::PriorityQueue.new
    expect(q.push(4)).to eq(4)
    expect(q.push(2)).to eq(2)
    expect(q.push(1)).to eq(1)
    expect(q.push(3)).to eq(3)
    expect(q.pop).to eq(4)
    expect(q.poll).to eq(3)
    expect(q.pop).to eq(2)
    expect(q.poll).to eq(1)
    expect(q.pop).to eq(nil)
  end

  class TestS < Struct.new(:a,:b)
  end

  it "should contain things that are pushed" do
    q = Utils::PriorityQueue.new {|x,y| x.a <=> y.a }
    a = TestS.new(1, "hi")
    b = TestS.new(2, "world")
    q.push(a)
    q.push(b)
    expect(q.include?(a)).to eq(true)
    expect(q.include?(b)).to eq(true)
    expect(q.poll).to eq(b)
    expect(q.poll).to eq(a)
    expect(q.pop).to eq(nil)
  end
end