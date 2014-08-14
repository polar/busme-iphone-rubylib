module Platform

  module MarkerMessageEventConstants
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


  class MarkerMessageEventData
    include MarkerMessageEventConstants
    attr_accessor :marker_info
    attr_accessor :thruUrl
    attr_accessor :resolve
    attr_accessor :resolveData
    attr_accessor :state
    attr_accessor :markerMessageForeground
    attr_accessor :markerMessageBackground

    def initialize(info)
      self.marker_info = info
      self.state       = S_PRESENT
    end
  end

  class MarkerMessageForeground
    include MarkerMessageEventConstants
    include Api::BuspassEventListener
    attr_accessor :api
    attr_accessor :markerController

    def initialize(api, controller)
      self.api = api
      self.markerController = controller
      api.uiEvents.registerForEvent("MarkerMessageEvent", self)
    end

    # Called from the UI Thread.
    def onBuspassEvent(event)
      event.eventData.markerMessageForeground = self
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
    # Should Overridden to display message
    def onPresent(eventData)
      # This should popup a message about the marker. The marker stays visible.
    end

    # Called on Foreground Thread by way of UI invoking
    #      eventData.marker_foreground.onInquired(eventData, resolution)
    # Should be called to resolve message with a resolution
    # Override to maybe get rid of message from display, or wait until onResolved
    def onInquired(eventData, resolve = nil)
      eventData.resolve = resolve if resolve
      eventData.state = S_INQUIRED
      api.bgEvents.postEvent("MarkerMessageEvent", eventData)
    end

    # Should Overridden to handle dismissal of message if needed.
    def onResolved(eventData)
      case eventData.resolve
        when R_GO
        when R_REMIND
          markerController.dismissMarker(eventData.marker_info, true, Time.now)
        when R_REMOVE
          markerController.dismissMarker(eventData.marker_info, false, Time.now)
        when R_CANCEL
      end
      eventData.state = S_DONE
      api.bgEvents.postEvent("MarkerMessageEvent", eventData)
    end

    # Should Overridden
    def onError(eventData)
      eventData.state = S_DONE
      api.bgEvents.postEvent("MarkerMessageEvent", eventData)
    end

    # Should Overridden
    def onDone(eventData)
    end
  end

  class MarkerMessageBackground
    include MarkerMessageEventConstants
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("MarkerMessageEvent", self)
    end

    # Called from Background Thread
    def onBuspassEvent(event)
      event.eventData.markerMessageBackground = self

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
      marker_info = eventData.marker_info
      case eventData.resolve
        when R_GO
          begin
            url = api.getMarkerClickThru(marker_info.id)
            eventData.thruUrl = url || eventData.marker_info.goUrl
          rescue Exception => boom
            eventData.thruUrl = eventData.marker_info.goUrl
          end
        when R_REMIND
        when R_REMOVE
        when R_CANCEL
      end
      eventData.state = S_RESOLVED
    rescue Exception => boom
      eventData.state = S_ERROR
    ensure
      api.uiEvents.postEvent("MarkerMessageEvent", eventData)
    end

    # May be Overridden
    def onError(eventData)
      api.uiEvents.postEvent("MarkerMessageEvent", eventData)
    end

    # May be  Overridden
    def onDone(eventData)
      api.uiEvents.postEvent("MarkerMessageEvent", eventData)
    end
  end
end
