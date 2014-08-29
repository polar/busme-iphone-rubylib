module Platform
  class MapSelectionEventController
    include JourneyDisplayUtility
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("Map:SelectionPathSearch", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "Map:SelectionPathSearch"
          processSelectionPathSearch(eventData)
      end
    end

    ## This method is performed on the background thread.
    # Fires off result to the foreground thread.
    def processSelectionPathSearch(eventData)
      result = pathSearch(eventData.journeyDisplays, eventData.geoPoint, eventData.zoomLevel)
      if result
        selected, unselected, touchGP = result
        evd = MapSelectionChangedEventData.new
        evd.selected = selected
        evd.unselected = unselected
        evd.geoPoint = touchGP
        api.uiEvents.postEvent("Map:SelectionChanged", evd)
      end
    end

  end
end