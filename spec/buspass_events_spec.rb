require "spec_helper"

class TestListener
  include Platform::BuspassEventListener
  attr_accessor :testEventName
  attr_accessor :testEventData
  attr_accessor :testEventTime

  def onBuspassEvent(event)
    self.testEventName = event.eventName
    self.testEventData = event.eventData
    self.testEventTime = Time.now
  end
end

describe Platform::BuspassEventNotifier do
  let(:event1) { Platform::BuspassEvent.new("A", [1,2])}
  let(:listener1) { TestListener.new() }
  let(:listener2) { TestListener.new() }
  let(:notifier) { Platform::BuspassEventNotifier.new("A") }

  it "should accept an event listener" do
    notifier.register(listener1)
    expect(notifier.eventListeners).to include(listener1)
  end

  it "should notify listener of event" do
    notifier.register(listener1)
    notifier.notifyEventListeners(event1)
    expect(listener1.testEventName).to eq(event1.eventName)
    expect(listener1.testEventData).to eq(event1.eventData)
  end

  it "should notify listeners of event in the order they were registered" do
    notifier.register(listener1)
    notifier.register(listener2)
    notifier.notifyEventListeners(event1)
    expect(listener2.testEventTime > listener1.testEventTime)
  end
end

describe Platform::BuspassEventDistributor do
  let(:event1) { Platform::BuspassEvent.new("A", [1,2])}
  let(:listener1) { TestListener.new() }
  let(:listener2) { TestListener.new() }
  let(:distributor) { Platform::BuspassEventDistributor.new }

  it "should register a buspass event and distribute it" do
    distributor.registerForEvent("A", listener1)
    distributor.triggerBuspassEvent(event1)

    expect(listener1.testEventName).to eq(event1.eventName)
    expect(listener1.testEventData).to eq(event1.eventData)
  end

  it "should register event with data and distribute it" do
    distributor.registerForEvent("A", listener1)
    distributor.registerForEvent("A", listener2)
    distributor.triggerEvent("A", [3,4])

    expect(listener1.testEventName).to eq("A")
    expect(listener1.testEventData).to eq([3,4])
    expect(listener2.testEventName).to eq("A")
    expect(listener2.testEventData).to eq([3,4])
    expect(listener2.testEventTime > listener1.testEventTime)
  end

  it "should register 2 events with data and distribute it" do
    distributor.registerForEvent("A", listener1)
    distributor.registerForEvent("B", listener2)
    distributor.triggerEvent("A", [3,4])

    expect(listener1.testEventName).to eq("A")
    expect(listener1.testEventData).to eq([3,4])
    expect(listener2.testEventName).to eq(nil)
    expect(listener2.testEventData).to eq(nil)

    distributor.triggerEvent("B", [1,2])

    expect(listener1.testEventName).to eq("A")
    expect(listener1.testEventData).to eq([3,4])
    expect(listener2.testEventName).to eq("B")
    expect(listener2.testEventData).to eq([1,2])
    expect(listener2.testEventTime > listener1.testEventTime)
  end
end