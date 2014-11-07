require "spec_helper"

describe Api::NameId do
  it "should parse simple name id" do
    nameid = Api::NameId.new("Name ", "1  ")
    expect(nameid.name).to eq("Name")
    expect(nameid.id).to eq("1")
  end

  it "should parse complex Route name id" do
    nameid = Api::NameId.new(["Name", "1", "R ", "100 "])
    expect(nameid.name).to eq("Name", )
    expect(nameid.id).to eq("1")
    expect(nameid.type).to eq("R")
    expect(nameid.version).to eq(100)
  end

  it "should parse complex Journey name id" do
    nameid = Api::NameId.new(["Name", "1", "V ", "340 ", "100 "])
    expect(nameid.name).to eq("Name", )
    expect(nameid.id).to eq("1")
    expect(nameid.type).to eq("V")
    expect(nameid.route_id).to eq("340")
    expect(nameid.version).to eq(100)
  end

  it "should parse complex Journey name id with start times" do
    time1 = Utils::Time.current
    time2 = Utils::Time.current + 3

    nameid = Api::NameId.new(["Name", "1", "V ", "340 ", "100 ", "#{time1.to_i}", "#{time2.to_i}"])
    expect(nameid.name).to eq("Name", )
    expect(nameid.id).to eq("1")
    expect(nameid.type).to eq("V")
    expect(nameid.route_id).to eq("340")
    expect(nameid.version).to eq(100)
    expect(nameid.sched_time_start).to eq(time1.to_i)
    expect(nameid.time_start).to eq(time2.to_i)
  end
end