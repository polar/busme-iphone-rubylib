require "spec_helper"

class A
  include Api::Encoding
  attr_accessor :at1
  attr_accessor :at2
  def propList
    %w(@at1 @at2)
  end
end

class B
  include Api::Encoding
  attr_accessor :at1
  attr_accessor :at2
  def propList
    %w(@at1 @at2)
  end
end

module C
  class D
    include Api::Encoding
    attr_accessor :at1
    def propList
      ["@at1"]
    end
  end
end

describe Api::Archiver do
  let(:number) {
    "<Number>5324234</Number>"
  }
  let(:string) {
    "<String>Hello there!</String>"
  }
  let(:boolean_true) {
    "<Boolean>true</Boolean>"
  }
  let(:boolean_false) {
    "<Boolean>false</Boolean>"
  }
  let(:float) {
    "<Number>54.3</Number>"
  }
  let(:hash) {
    "<Hash><HashItem><Key><String>Hello There</String></Key><Value><Number>34543</Number></Value></HashItem></Hash>"
  }
  let(:array) {
    "<Array><Item index='0'>#{boolean_false}</Item><Item index='1'>#{float}</Item><Item index='2'>#{string}</Item></Array>"
  }
  let(:obj1) {
    A.new.tap do |a|
      a.at1 = 34
      a.at2 = "Hello There!"
    end
  }
  let(:obj1lit) {
    "<A id='70190458451860'><Item key='_imid_'><String>A:70190458451860</String></Item><Item key='__imr__'><Boolean>true</Boolean></Item><Item key='@at1'><Number>34</Number></Item><Item key='@at2'><String>Hello There!</String></Item></A>
"
  }

  let(:obj2) {
    A.new.tap do |a|
      a.at1 = B.new
      a.at1.at1 = a
    end
  }

  it "should parse Number" do
    val = Api::Archiver.decode(number)
    val == 5324234
  end

  it "should encode Number" do
    val = Api::Archiver.encode(5324234)
    expect(val).to eq(number)
  end
  it "should parse String" do
    val = Api::Archiver.decode(string)
    expect(val).to eq( "Hello there!")
  end

  it "should encode String" do
    val = Api::Archiver.encode("Hello there!")
    expect(val).to eq(string)
  end

  it "should parse Boolean" do
    val = Api::Archiver.decode(boolean_true)
    expect(val).to eq(true)
    val = Api::Archiver.decode(boolean_false)
    expect(val).to eq(false)
  end

  it "should encode Boolean" do
    val = Api::Archiver.encode(true)
    expect(val).to eq(boolean_true)
    val = Api::Archiver.encode(false)
    expect(val).to eq(boolean_false)
  end

  it "should parse Hash" do
    val = Api::Archiver.decode(hash)
    expect(val).to be_a_kind_of Hash
    val.each do |k,v|
      expect(k).to eq("Hello There")
      expect(v).to eq(34543)
    end
  end

  it "should encode Hash" do
    val = Api::Archiver.encode({"Hello There" => 34543})
    expect(val).to eq(hash)
  end

  it "should parse Array" do
    val = Api::Archiver.decode(array)
    expect(val).to be_a_kind_of Array
    expect(val[0]).to eq(false)
    expect(val[2]).to eq("Hello there!")
    expect(val[1]).to eq(54.3)
  end

  it "should enocde Array" do
    val = Api::Archiver.encode([false, 54.3, "Hello there!"])
    expect(val).to eq(array)
  end

  it "should parse object" do
    val = Api::Archiver.decode(obj1lit)
    expect(val).to be_a_kind_of A
    expect(val.at1).to eq 34
    expect(val.at2).to eq("Hello There!")
  end

  it "should encode object" do
    val = Api::Archiver.encode(obj1)

    expect(val.gsub(/[0-9]/,"X")+"\n").to eq(obj1lit.gsub(/[0-9]/, "X"))
  end

  it "should encode and decode object" do
    val = Api::Archiver.encode(obj1)
    obj = Api::Archiver.decode(val)
    expect(obj1.at1).to eq(obj.at1)
    expect(obj1.at2).to eq(obj.at2)
  end

  it "should encode and decode object with identity map" do
    val = Api::Archiver.encode(obj2)
    obj = Api::Archiver.decode(val)
    expect(obj.at1).to be_a_kind_of B
    expect(obj.at2).to eq(nil)
    expect(obj.at1.at1).to be obj
  end

  it "should encode module classes" do
    val = Api::Archiver.encode(C::D.new)
    puts val
    obj = Api::Archiver.decode(val)

  end
end