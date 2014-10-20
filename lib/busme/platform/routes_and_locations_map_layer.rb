module Platform
  module Disposition
    TRACK = 1
    HIGHLIGHT = 2
    NORMAL = 3

    TOO_EARLY = 5
    START = 6
  end

  class RoutesAndLocationsMapLayer
    attr_accessor :api
    attr_accessor :journeyDisplayController
    attr_accessor :mustDrawPaths
    attr_accessor :doDraw

    PATTERN_PLACING_THRESHOLD = 10

    def initialize(api, journeyDisplayController)
      self.api = api
      self.mustDrawPaths = true
      self.doDraw = true
      self.journeyDisplayController = journeyDisplayController
    end

    ##
    # TODO: Extend to get a location object from the device
    def getCurrentLocation
      nil
    end

    ##
    # This function can be extended in Android to transform the pattern
    # into a path at the current projection and draw it, or place it as a MKPolyline
    # in iOS.
    def placePattern(pattern, disposition, context)

    end

    ##
    # Places a directional locator on the map at location according to direction and
    # a visual for disposition and reported. It may also place text on the screen as well
    # in conjunction with the locator.
    #
    def placeJourneyLocator(journeyDisplay, location, direction, reported, disposition, context)

    end

    ##
    # Places the JourneyLocation on the MapLayer according to the disposition
    # It places them in the call order, the last being on top. The postingRoute
    # is always on the top.
    #
    def placeJourneyLocation(journeyDisplay, disposition, context)
      time_now = Time.now
      if journeyDisplay.route.isReporting?
        isReported = true
        loc = getCurrentLocation()
        if loc
          currentLocation = GeoCalc.toGeoPoint(location)
          currentDirection = currentLocation.bearing.
          points = GeoPathUtils.whereOnPath(journeyDisplay.paths[0], currentLocation, 60)
          for gp in points
            if gp.distance > 0
              currentDirection = gp.bearing
            end
          end
          currentTimeDiff = 0
          onRoute = true
        end
      end
      startMeasure = journeyDisplay.route.getStartingMeasure(api.activeStartDisplayThreshold, time_now)
      if currentLocation
        journeyDisplay.route.tap do |route|
          isReported = route.isReported?
          currentLocation = route.lastKnownLocation
          currentDirection = route.lastKnownDirection
          distance = route.lastKnownDistance
          currentTimeDiff = route.lastKnownTimeDiff
          onRoute = route.onRoute
        end
      end
      if currentLocation && startMeasure < 1.0
        if startMeasure < 0
          if disposition == Disposition::NORMAL
            return
          end
          disposition = Disposition::TOO_EARLY
        else
          disposition = Disposition::START
        end
        currentLocation = journeyDisplay.route.getStartingPoint
        currentDirection = 0.0 # doesn't matter.
        currentTimeDiff = 0
      end
      if currentLocation.nil?
        return
      end
      text = ""
      diff = currentTimeDiff/60
      time = "%sm" % diff.abs
      # < 0 means early
      # > 0 means late
      placeJourneyLocator(journeyDisplay, currentLocation, currentDirection, isReported, disposition, context)
    end

    def placeJourneyLocations(journeyDisplays, context)
      postingRoute = nil
      placed = 0
      for jd in journeyDisplays
        if jd.isPathVisible? && jd.route.isJourney?
          if jd.route.isReporting?
            postingRoute = jd
          else
            if ! jd.route.isFinished?
              if (self.mustPlacePaths || placed <= PATTERN_PLACING_THRESHOLD)
                placeJourneyLocation(jd, Disposition::NORMAL, context)
                placed += 1
              end
            end
          end
        end
      end
      placeJourneyLocation(postingRoute, Disposition::NORMAL, context)
    end

    ##
    # This function should be extended to place the journey's name
    # at a standard part of the screen.
    #
    def placeJourneyLabel(journeyDisplay, disposition, context)
      # Place this at the bottom of the screen
      label = journeyDisplay.route.name
    end

    def placePatterns(patterns, disposition, context)
      lastNumberOfPathsVisible = 0
      placed = {}
      for pat in patterns
        if p.isReady?
          if mustPlacePaths || lastNumberOfPathsVisible < PATTERN_PLACING_THRESHOLD
            if placed[pat.id].nil?
              placePattern(pat, disposition, context)
              placed[pat.id] = pat
              lastNumberOfPathsVisible += 1
            end
          else
            break
          end
        end
      end
    end

    def placeRoutes(journeyDisplays, context)
      patterns = journeyDisplays.reduce([]) {|t,v| t + v.journeyPatterns}
      placePatterns(patterns, Disposition::NORMAL, context)
    end

    def placeRoute(journeyDisplay, disposition, context)
      placePatterns(journeyDisplay.journeyPatterns, disposition, context)
    end

    def place(context)
      if ! doDraw
        return
      end
      if journeyDisplayController.trackingJourneyDisplay
        placeRoute(journeyDisplayController.trackingJourneyDisplay, Disposition::TRACK, context)
      elsif journeyDisplayController.highlightJourneyDisplay
        placeRoute(journeyDisplayController.highlightJourneyDisplay, Disposition::HIGHLIGHT, context)
      else
        placeRoutes(journeyDisplayController.journeyDisplays, context)
        placeJourneyLocations(journeyDisplayController.journeyDisplays, context)
      end
    end

  end
end