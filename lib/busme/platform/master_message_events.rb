module Platform
  
  module MasterMessageEventConstants
    S_PRESENT  = 0
    S_INQUIRED = 1
    S_RESOLVED = 2
    S_ERROR    = 3
    S_DONE     = 4

    R_GO     = 1
    R_REMIND = 2
    R_REMOVE = 3
    R_CANCEL = 4
  end
  

  class MasterMessageEventData
    include MasterMessageEventConstants
    attr_accessor :masterMessage
    attr_accessor :thruUrl
    attr_accessor :resolve
    attr_accessor :resolveData
    attr_accessor :state
    attr_accessor :masterMessageForeground
    attr_accessor :masterMessageBackground

    def initialize(message)
      self.masterMessage = message
      self.state       = S_PRESENT
    end
  end

  class MasterMessageForeground
    include MasterMessageEventConstants
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("MasterMessageEvent", self)
    end

    # Called from the UI Thread.
    def onBuspassEvent(event)
      event.eventData.masterMessageForeground = self
      case event.eventData.state
        when S_PRESENT
          onPresent(event.eventData)
        when S_RESOLVED
          onResolved(event.eventData)
        when S_ERROR
          onError(event.eventData)
        when S_DONE
          onDone(event.eventData)
        else
      end
    end

    # Called from UI Thread
    # Should override to display message
    def onPresent(eventData)
      eventData.masterMessage.onDisplay(Time.now)
    end

    # Called on Foreground Thread by way of UI invoking
    #      eventData.masterMessageForeground.onInquired(eventData, resolution)
    # Should be called to resolve message with a resolution
    # Override to maybe get rid of message from display, or wait until onResolved
    def onInquired(eventData, resolve = nil)
      eventData.resolve = resolve if resolve
      eventData.state = S_INQUIRED
      api.bgEvents.postEvent("MasterMessageEvent", eventData)
    end

    # Should Overridden to handle dismissal of message if needed.
    def onResolved(eventData)
      case eventData.resolve
        when R_GO
        when R_REMIND
        when R_REMOVE
        when R_CANCEL
      end
      eventData.state = S_DONE
      api.bgEvents.postEvent("MasterMessageEvent", eventData)
    end

    # Should Overridden
    def onError(eventData)
      eventData.state = S_DONE
      api.bgEvents.postEvent("MasterMessageEvent", eventData)
    end

    # Should Overridden
    def onDone(eventData)
    end
  end

  class MasterMessageBackground
    include MasterMessageEventConstants
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("MasterMessageEvent", self)
    end

    # Called from Background Thread
    def onBuspassEvent(event)
      event.eventData.masterMessageBackground = self

      case event.eventData.state
        when S_INQUIRED
          onInquired(event.eventData)
        when S_ERROR
          onError(event.eventData)
        when S_DONE
          onDone(event.eventData)
      end
    end


    # Called from Background Thread
    def onInquired(eventData)
      masterMessage = eventData.masterMessage
      case eventData.resolve
        when R_GO
          begin
            url = api.getMasterMessageClickThru(masterMessage.id)
            eventData.thruUrl = url ||  masterMessage.goUrl
          rescue Exception => boom
            eventData.thruUrl = masterMessage.goUrl
          end
          eventData.masterMessage.onDismiss(true, Time.now)
        when R_REMIND
          # We really do not have a remind. Same as cancel
          eventData.masterMessage.onDismiss(true, Time.now)
        when R_REMOVE
          eventData.masterMessage.onDismiss(false, Time.now)
        when R_CANCEL
          eventData.masterMessage.onDismiss(true, Time.now)
      end
      eventData.state = S_RESOLVED
    rescue Exception => boom
      eventData.state = S_ERROR
    ensure
      api.uiEvents.postEvent("MasterMessageEvent", eventData)
    end

    # May be Overridden
    def onError(eventData)
      api.uiEvents.postEvent("MasterMessageEvent", eventData)
    end

    # May be  Overridden
    def onDone(eventData)
      api.uiEvents.postEvent("MasterMessageEvent", eventData)
    end
  end
end
