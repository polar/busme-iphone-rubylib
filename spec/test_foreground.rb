class TestForeground
  attr_accessor :api
  attr_writer :lastEvent
  def initialize(api, events)
    self.api = api
    events.each do |eventName|
      api.uiEvents.registerForEvent(eventName, self)
    end
  end

  def onBuspassEvent(event)
    self.lastEvent = event
  end

  def lastEvent
    @lastEvent.tap do
      self.lastEvent = nil
    end
  end
end