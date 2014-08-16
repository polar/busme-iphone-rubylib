module Platform
  class ProgressEventData
    attr_accessor :nRoutes
    attr_accessor :iRoute
    attr_accessor :action

    A_ON_SYNC_START  = 1
    A_ON_SYNC_END    = 2
    A_ON_ROUTE_START = 3
    A_ON_ROUTE_END   = 4
    A_ON_DONE        = 5
  end

  class ProgressForeground
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("JourneyProgress", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a?(ProgressEventData)
        case eventData.action
          when ProgressEventData::A_ON_SYNC_START
            onSyncStart(eventData)
          when ProgressEventData::A_ON_SYNC_END
            onSyncEnd(eventData)
          when ProgressEventData::A_ON_ROUTE_START
            onRouteStart(eventData)
          when ProgressEventData::A_ON_ROUTE_END
            onRouteEnd(eventData)
          when ProgressEventData::A_ON_DONE
            onDone(eventData)
        end
      end
    end

    def onSyncStart(eventData)

    end

    def onSyncEnd(eventData)

    end

    def onRouteStart(eventData)

    end

    def onRouteEnd(eventData)

    end

    def onDone(eventData)

    end
  end

  class ProgressBackground
    include JourneyBasket::ProgressListener
    attr_accessor :api
    attr_accessor :nRoutes
    attr_accessor :iRoute

    def initialize(api)
      self.api = api
    end

    def onSyncStart()
      eventData = ProgressEventData.new
      eventData.action = ProgressEventData::A_ON_SYNC_START
      api.uiEvents.postEvent("JourneyProgress", eventData)
    end

    def onSyncEnd(nRoutes)
      eventData = ProgressEventData.new
      self.nRoutes = nRoutes
      eventData.action = ProgressEventData::A_ON_SYNC_END
      eventData.nRoutes = nRoutes
      api.uiEvents.postEvent("JourneyProgress", eventData)
    end

    def onRouteStart(iRoute)
      eventData = ProgressEventData.new
      eventData.action = ProgressEventData::A_ON_ROUTE_START
      eventData.nRoutes = nRoutes
      eventData.iRoute = iRoute
      api.uiEvents.postEvent("JourneyProgress", eventData)
    end

    def onRouteEnd(iRoute)
      eventData = ProgressEventData.new
      eventData.nRoutes = nRoutes
      eventData.action = ProgressEventData::A_ON_ROUTE_END
      eventData.iRoute = iRoute
      api.uiEvents.postEvent("JourneyProgress", eventData)
    end

    def onDone()
      eventData = ProgressEventData.new
      eventData.nRoutes = nRoutes
      eventData.action = ProgressEventData::A_ON_DONE
      api.uiEvents.postEvent("JourneyProgress", eventData)
    end
  end
end