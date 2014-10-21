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
      self.eventListeners << eventListener
    end

    def unregister(eventListener)
      self.eventListeners.delete(eventListener)
    end

    def reset
      self.eventListeners = []
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

  module BuspassEventPostListener
    def onPostEvent(queue)

    end
  end

  class BuspassEventDistributor
    attr_accessor :eventNotifiers
    attr_accessor :eventQ
    attr_accessor :postEventListener
    attr_accessor :name

    def initialize(args = {})
      self.eventNotifiers = {}
      self.eventQ = args[:queue] || Utils::Queue.new
      self.name = args[:name]
    end

    def postEvent(event, data = nil)
      puts "#{self.to_s}.postEvent(#{event})"
      event = event.is_a?(BuspassEvent) ? event : BuspassEvent.new(event, data)
      postBuspassEvent(event)
    end

    def postBuspassEvent(event)
      eventQ.push(event)
      postEventListener.onPostEvent(self) if postEventListener
    end

    def peek
      eventQ.peek
    end

    alias :top :peek

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
      new_event = event.is_a?(BuspassEvent) ? event : BuspassEvent.new(event, data)
      triggerBuspassEvent(new_event)
    end

    def triggerBuspassEvent(event)
      notifier = eventNotifiers[event.eventName]
      if notifier
        notifier.notifyEventListeners(event)
      else
        puts "No receptors for Event #{event.eventName} on #{self.to_s}"
      end
    end

    def registerForEvent(eventName, eventListener)
      puts "#{self}: Register for #{eventName} lis = #{eventListener}"
      notifier = eventNotifiers[eventName] ||= BuspassEventNotifier.new(eventName)
      notifier.register(eventListener)
    end

    def unregisterForEvent(eventName, eventListener)
      notifier = eventNotifiers[eventName]
      notifier.unregister(eventListener) if notifier
    end

    def clearRegistrationsForEvent(eventName)
      notifier = eventNotifiers[eventName]
      notifier.reset if notifier
    end

    def to_s
      name ? "BPD(#{name})" : super.to_s
    end
  end

end