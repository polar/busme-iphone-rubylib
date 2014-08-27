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
      eventData = event.eventData
      case event.eventName
        when "MarkerPresent:Add"
          addMarker(eventData)
        when "MarkerPreset:Remove"
          removeMarker(eventData)
      end
    end

    def addMarker(eventData)
      raise "NotImplemented"
    end

    def removeMarker(eventData)
      raise "NotImplemented"
    end
  end

end