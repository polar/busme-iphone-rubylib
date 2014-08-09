module Platform
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

    def initialize
      self.eventNotifiers = {}
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