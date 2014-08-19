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

    def selectFromTouchOnLocator(journeyDisplays, touchRect, projection)
      ret = []
      for journeyDisplay in journeyDisplays
        if journeyDisplay.pathVisible
          if journeyDisplay.route.isJourney?
            if !journeyDisplay.isActive? && journeyDisplay.route.isTimeless?
              # we should already have projected paths that need to be translated to the zoomlevel.
              iPath = 0
              for path in journeyDisplay.route.projectedPaths
                if path
                  if PathUtils.isOnPath(path, touchRect.center, [touchRect.width, touchRect.height].max)
                    ret << journey
                  end
                end
                iPath += 1
              end
            else
              loc = journey.route.lastKnownLocation
              if loc
                rect = touchRect.dup
                screenCoords = projection.toMapPixels(loc)
                rect.offsetTo(screenCoords.x, screenCoords.y)
              end
            end
          end
        end
      end
    end

  end
end