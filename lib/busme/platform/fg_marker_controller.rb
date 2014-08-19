module Platform
  class FGMarkerController
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvent.registerForEvent("Marker:Add", self)
      api.uiEvent.registerForEvent("Marker:Remove", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "Marker:Add"
          onAddMarker(eventData)
        when "Marker:Remove"
          onRemoveMarker(eventData)
      end
    end

    def onAddMarker(eventData)

    end

    def onRemoveMarker(eventData)

    end

  end
end