module Platform

  class MarkerEventData
    attr_accessor :marker_info
    attr_accessor :thruUrl
    attr_accessor :optionClicked
    attr_accessor :state

    S_CLICK   = 1
    S_CLICKED = 2
    S_ERROR   = 3
    S_DONE    = 4

    OPT_GO     = 1
    OPT_REMIND = 2
    OPT_REMOVE = 3
    OPT_CANCEL = 4

    def initialize(info)
      self.marker_info = info
      self.state       = S_CLICK
    end
  end

  class MarkerForeground
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("MarkerEvent", self)
    end

    # Called from the UI Thread.
    def onBuspassEvent(event)
      case event.eventData.optionClicked
        when OPT_GO
        when OPT_REMIND
        when OPT_REMOVE
        when OPT_CANCEL
      end
      presentMarkerClickThrough(event.eventData)
    end

    def presentMarkerClickThrough(evenData)
      raise "NotImplemented"
    end
  end

  class MarkerBackground
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("MarkerEvent", self)
    end

    # Called from Background Thread
    def onBuspassEvent(event)
      recordClickThru(event)
    end

    # Called from Background Thread
    def recordClickThru(event)
      marker_info = event.eventData.marker_info
      case event.eventData.optionClicked
        when OPT_GO
          url = api.getMarkerClickThru(marker_info.id)
          event.eventData.thruUrl = url
        when OPT_REMIND
        when OPT_REMOVE
        when OPT_CANCEL
      end
      event.eventData.state   = Platform::MarkerEventData::S_CLICKED
    rescue Exception => boom
      event.eventData.state = Platform::MarkerEventData::S_ERROR
    ensure
      api.uiEvents.postEvent(event)
    end
  end
end