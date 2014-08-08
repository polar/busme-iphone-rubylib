module Platform
  class BuspassEvent
    attr_accessor :eventName
    attr_accessor :eventData

    def initialize(name, data)
      self.eventName = name
      self.eventData = data
    end

    def to_s
      "BuspassEvent:#{eventName}"
    end

  end
end