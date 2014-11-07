module Platform
  module JourneySyncProgressEventDataConstants
    P_BEGIN       = 1
    P_SYNC_START  = 2
    P_SYNC_END    = 3
    P_ROUTE_START = 4
    P_ROUTE_END   = 5
    P_IOERROR     = 6
    P_DONE        = 7
  end

  class JourneySyncProgressEventData
    include JourneySyncProgressEventDataConstants

    attr_accessor :action
    attr_accessor :nRoutes
    attr_accessor :iRoute
    attr_accessor :beginTime
    attr_accessor :syncStartTime
    attr_accessor :syncEndTime
    attr_accessor :routeTimes
    attr_accessor :endTime
    attr_accessor :ioError
    attr_accessor :isForced

    def initialize
      self.action = P_BEGIN
      self.routeTimes = []
    end

    def dup
      evd = JourneySyncProgressEventData.new
      evd.action = action
      evd.nRoutes = nRoutes
      evd.iRoute = iRoute
      evd.beginTime = beginTime
      evd.syncStartTime = syncStartTime
      evd.syncEndTime = syncEndTime
      evd.routeTimes = routeTimes
      evd.endTime = endTime
      evd.ioError = ioError
      evd.isForced = isForced
      evd
    end
  end

  class JourneySyncProgressEventListener
    include JourneySyncProgressEventDataConstants
    include JourneyBasket::ProgressListener
    include JourneyBasket::OnIOErrorListener
    attr_accessor :api

    attr_accessor :eventData

    def initialize(api)
      self.api = api
    end

    def onBegin(isForced)
      self.eventData = JourneySyncProgressEventData.new
      eventData.beginTime = Utils::Time.current
      eventData.isForced = isForced
      api.uiEvents.postEvent("JourneySyncProgress", eventData.dup)
    end

    def onSyncStart
      eventData.action = P_SYNC_START
      eventData.syncStartTime = Utils::Time.current
      api.uiEvents.postEvent("JourneySyncProgress", eventData.dup)
    end

    def onSyncEnd(nRoutes)
      eventData.action = P_SYNC_END
      eventData.syncEndTime = Utils::Time.current
      eventData.nRoutes = nRoutes
      api.uiEvents.postEvent("JourneySyncProgress", eventData.dup)
    end

    def onRouteStart(iRoute)
      eventData.action = P_ROUTE_START
      eventData.routeTimes[iRoute] = {:start => Utils::Time.current}
      eventData.iRoute = iRoute
      api.uiEvents.postEvent("JourneySyncProgress", eventData.dup)
    end

    def onRouteEnd(iRoute)
      eventData.action = P_ROUTE_END
      eventData.routeTimes[iRoute].merge(:end => Utils::Time.current)
      eventData.iRoute = iRoute
      api.uiEvents.postEvent("JourneySyncProgress", eventData.dup)
    end

    def onIOError(basket, boom)
      eventData.action = P_IOERROR
      eventData.ioError = boom
      api.uiEvents.postEvent("JourneySyncProgress", eventData.dup)
    end

    def onDone
      eventData.action = P_DONE
      eventData.endTime = Utils::Time.current
      api.uiEvents.postEvent("JourneySyncProgress", eventData.dup)
    end
  end
end