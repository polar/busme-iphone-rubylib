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
      PM.logger.info "BuspassEventNotifier: notify #{event.eventName}"
      PM.logger.info "BuspassEventNotifier: notify #{eventListeners.size} listeners"
      PM.logger.info "BuspassEventNotifier: notify make array #{[]}"
      eventListeners.each do |lis|
        PM.logger.info "BuspassEventNotifier: notifying #{lis}"
        PM.logger.info "BuspassEventNotifer: array make #{[]}"
        lis.onBuspassEvent(event)
        PM.logger.info "BuspassEventNotifier: notified #{lis}"
        PM.logger.info "BuspassEventNotifier: notified make array #{[]}"
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
      PM.logger.info "#{self.to_s}.postEvent(event #{event}, data #{data})"
      PM.logger.info "#{self.to_s}.postEvent(event #{event}, data #{data}) #{[]}"
      event = event.is_a?(BuspassEvent) ? event : BuspassEvent.new(event, data)
      postBuspassEvent(event)
    end

    def postBuspassEvent(event)
      eventQ.push(event)
      postEventListener.onPostEvent if postEventListener
    end

    def peek
      eventQ.peek
    end

    alias :top :peek

    def roll
      PM.logger.info "#{self}: roll1"
      PM.logger.info "#{self}: roll1 #{[]}"
      event = eventQ.pop
      PM.logger.info "#{self}: roll2 #{event}"
      PM.logger.info "#{self}: roll2 #{[]}"
      if event
        PM.logger.info "#{self}: roll3 #{event} #{event.eventName}"
        PM.logger.info "#{self}: roll3 #{event} #{event.eventName} #{[]}"
        triggerBuspassEvent(event)
        PM.logger.info "#{self}: roll4 #{event}"
        PM.logger.info "#{self}: roll4 #{event} #{[]}"
      end
      PM.logger.info "#{self}: roll5 #{event}"
      PM.logger.info "#{self}: roll5 #{event} #{[]}"
      event
    end

    def rollAll
      event = roll
      PM.logger.info "#{self}: rollAll #{event}"
      PM.logger.info "#{self}: rollAll #{event} #{[]}"
      while event do
        event = roll
        PM.logger.info "#{self}: rollAll #{event}"
        PM.logger.info "#{self}: rollAll #{event} #{[]}"
      end
    end

    def triggerEvent(event, data = nil)
      new_event = event.is_a?(BuspassEvent) ? event : BuspassEvent.new(event, data)
      triggerBuspassEvent(new_event)
    end

    def triggerBuspassEvent(event)
      PM.logger.info "triggerBuspassEvent #{event.eventName}"
      PM.logger.info "triggerBuspassEvent #{[]}"
      notifier = eventNotifiers[event.eventName]
      PM.logger.info "triggerBuspassEvent notifier #{notifier}"
      if notifier
        notifier.notifyEventListeners(event)
      else
        PM.logger.info "No receptors for Event #{event.eventName} on #{self.to_s}"
      end
    end

    def registerForEvent(eventName, eventListener)
     #puts "#{self}: Register for #{eventName} lis = #{eventListener}"
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