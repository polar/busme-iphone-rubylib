module Platform
  class JourneyEventController
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("JourneyEvent", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a?(JourneyEventData)
        case eventData.action
          when JourneyEventData::A_ON_ROUTE_POSTING
            onRoutePosting(eventData)
          when JourneyEventData::A_AT_ROUTE_START
            atRouteStart(eventData)
          when JourneyEventData::A_OFF_ROUTE
            offRoute(eventData)
          when JourneyEventData::A_ON_ROUTE
            onRoute(eventData)
          when JourneyEventData::A_UPDATE_ROUTE
            updateRoute(eventData)
          when JourneyEventData::A_AT_ROUTE_END
            atRouteEnd(eventData)
          when JourneyEventData::A_ON_ROUTE_DONE
            onRouteDone(eventData)
        end
      end
    end

    def onRoutePosting(eventData)

    end

    def atRouteStart(eventData)

    end

    def offRoute(eventData)

    end

    def onRoute(eventData)

    end

    def updateRoute(eventData)

    end

    def atRouteEnd(eventData)

    end

    def onRouteDone(eventData)

    end
  end

end