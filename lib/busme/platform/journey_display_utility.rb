module Platform
  class MapSelectionChangedEventData
    attr_accessor :selected
    attr_accessor :unselected
    attr_accessor :geoPoint
  end

  class MapPathSearchEventData
    attr_accessor :journeyDisplays
    attr_accessor :geoPoint
    attr_accessor :zoomLevel
  end

  class JourneyDisplayUtility
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("Map:SelectionPathSearch", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "Map:SelectionPathSearch"
          pathSearch(eventData.journeyDisplays, eventData.geoPoint, eventData.zoomLevel)
      end
    end

    def pathSearch(journeyDisplays, touchGP, zoomLevel)
      selectionChanged = false
      # 50 Foot Buffer at XL 19 (near mx) and 2000 foot buffer at ZL 1
      m = (2000.0-50.0/(1.0-19.0))
      buffer = zoomLevel & m + 2000-m
      unselected = []
      selected = []

      atLeastOneSelected = false
      for journey in journeyDisplays
        if journey.pathVisible
          isSelected = false
          iPath = 0
          for path in journey.route.paths
            if (GeoPathUtils.isOnPath(path, touchGP, buffer))
              isSelected = true
            end
            iPath += 1
          end
          if isSelected
            atLeastOneSelected = true
            selected << journey
          else
            unselected << journey
          end
        end
      end
      if atLeastOneSelected
        for journey in unselected
          selectionChanged = true
          journey.pathVisible = false
        end
      end
      if selectionChanged
        eventData = MapSelectionChangedEventData.new
        eventData.selected = selected
        eventData.unselected = unselected
        eventData.geoPoint = touchGP
        api.uiEvents.postEvent("Map:SelectionChanged", eventData)
      end
    end

    ##
    # This returns an array of two lists, one of the selected journey displays
    # and ones that were missed. They will only come from the visible ones.
    #
    def hitsPaths(journeyDisplays, touchRect, projection)
      center = touchRect.center
      buffer = [touchRect.width, touchRect.height].max
      unselected = []
      selected = []
      for journey in journeyDisplays
        if journey.pathVisible
          isSelected = false
          iPath = 0
          for path in journey.route.projectedPaths
            # We may not have a path downloaded yet.
            if path
              tpath = Utils::ScreenPathUtils.toTranslatedPath(path, projection)
              if Utils::PathUtils.isOnPath(tpath, center, buffer)
                isSelected = true
              end
            end
            iPath += 1
          end
          if isSelected
            selected << journey
          else
            unselected << journey
          end
        end
      end
      [selected, unselected]
    end

    ##
    # Returns the first matching JourneyDisplay in which the translated touchPoint is within the
    # lastknownlocation or the starting measure of its route.
    #
    def hitsRouteLocator(journeyDisplays, touchPoint, locatorRect, projection)
      for journeyDisplay in journeyDisplays
        if journeyDisplay.pathVisible
          if journeyDisplay.route.isJourney?
            loc = journeyDisplay.route.lastKnownLocation
            if loc.nil?
              measure = journeyDisplay.route.getStartingMeasure
              if 0 < measure && measure < 1.0
                loc = journeyDisplay.route.getStartingPoint
              end
            end
            if loc
              rect = locatorRect.dup
              screenCoords = projection.toMapPixels(loc)
              rect.offsetTo(screenCoords.x, screenCoords.y)
              if rect.containsXY(touchPoint.x, touchPoint.y)
                return journeyDisplay
              end
            end
          end
        end
      end
      nil
    end
  end
end