module Platform
  class FG_JourneySyncProgressEventController
    include Api::BuspassEventListener
    include JourneySyncProgressEventDataConstants

    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("JourneySyncProgress", self)
    end

    def onBuspassEvent(event)
     #puts "#{self}: onBuspassEvent(#{event.eventName})"
     #puts " onBupassEvent make Array #{[]}"
      eventData = event.eventData
      case eventData.action
        when P_BEGIN
          onBegin(eventData)
        when P_SYNC_START
          onSyncStart(eventData)
        when P_SYNC_END
          onSyncEnd(eventData)
        when P_ROUTE_START
          onRouteStart(eventData)
        when P_ROUTE_END
          onRouteEnd(eventData)
        when P_DONE
          onDone(eventData)
        when P_IOERROR
          onIOError(eventData)
      end
     #puts "#onBuspassEvent end(#{event.eventName})"
     #puts "#onBupassEvent end make Array #{[]}"
    end

    def present(eventData)

    end

    def onBegin(eventData)

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

    def onIOError(eventData)

    end
  end
end