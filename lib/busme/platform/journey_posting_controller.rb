module Platform
  class JourneyLocationEventData
    attr_accessor :route
    attr_accessor :location
    attr_accessor :role

    def initialize(route, location, role)
      self.role = role
      self.route = route
      self.location = location
    end
  end

  class JourneyPostingController
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("JourneyLocationPost", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a?(JourneyLocationEventData)
        postLocation(eventData)
      end
    end

    def postLocation(eventData)
      result = api.postJourneyLocation(eventData.route, eventData.location, eventData.role)
      case result
        when "ok"
        when "notavailable"
          # Should probably stop posting
        when "notloggedin"
          api.uiEvents.postEvent("ServerLogout")
      end
      result
    end
  end

end