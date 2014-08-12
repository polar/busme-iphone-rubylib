module Api
  class BuspassEvent
    attr_accessor :eventName
    attr_accessor :eventData
    def initialize(name, data)
      self.eventName = name
      self.eventData = data
    end
  end

  class BuspassEventNotifier
    attr_accessor :eventName
    attr_accessor :eventListeners

    def initialize(name)
      self.eventName = name
      self.eventListeners = []
    end

    def register(eventListener)
      eventListeners << eventListener
    end

    def notifyEventListeners(event)
      eventListeners.each do |lis|
        lis.onBuspassEvent(event)
      end
    end
  end

  module BuspassEventListener
    def onBuspassEvent(buspassEvent)
      raise "NotImplemented"
    end
  end

  class BuspassEventDistributor
    attr_accessor :eventNotifiers
    attr_accessor :eventQ

    def initialize
      self.eventNotifiers = {}
      self.eventQ = Utils::PriorityQueue.new
    end

    def postEvent(event, data = nil)
      event = event.is_a?(BuspassEvent) ? event : BuspassEvent.new(event, data)
      postBuspassEvent(event)
    end

    def postBuspassEvent(event)
      eventQ.push(event)
    end

    def roll
      event = eventQ.pop
      if event
        triggerBuspassEvent(event)
      end
      event
    end

    def rollAll
      event = roll
      while event do
        event = roll
      end
    end

    def triggerEvent(event, data = nil)
      event = event.is_a?(BuspassEvent) ? event : BuspassEvent.new(event, data)
      triggerBuspassEvent(event)
    end

    def triggerBuspassEvent(event)
      notifier = eventNotifiers[event.eventName]
      if notifier
        notifier.notifyEventListeners(event)
      else
        raise "UnknownEvent"
      end
    end

    def registerForEvent(eventName, eventListener)
      notifier = eventNotifiers[eventName] ||= BuspassEventNotifier.new(eventName)
      notifier.register(eventListener)
    end
  end

end