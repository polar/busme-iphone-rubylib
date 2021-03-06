module Platform
  ##
  # This class merely handles event processing for the MarkerPresentationController
  #
  class FG_MarkerPresentationEventController
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("MarkerPresent:Add", self)
      api.uiEvents.registerForEvent("MarkerPresent:Remove", self)
    end

    def onBuspassEvent(event)
      puts "FG Marker Presentation Event Controller. got event #{event.eventName}"
      eventData = event.eventData
      case event.eventName
        when "MarkerPresent:Add"
          presentMarker(eventData)
        when "MarkerPresent:Remove"
          abandonMarker(eventData)
      end
    end

    def presentMarker(eventData)
      raise "NotImplemented"
    end

    def abandonMarker(eventData)
      raise "NotImplemented"
    end
  end

end