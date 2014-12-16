module Platform
  module Disposition
    TRACK = 1
    HIGHLIGHT = 2
    NORMAL = 3
  end
  module IconType
    NORMAL = 4
    REPORTING = 5
    TOO_EARLY = 6
    START = 7
  end

  class RoutesAndLocationsMapLayer
    attr_accessor :api
    attr_accessor :journeyDisplayController
    attr_accessor :mustPlacePaths
    attr_accessor :doDraw

    PATTERN_PLACING_THRESHOLD = 10

    def initialize(api, journeyDisplayController)
      self.api = api
      self.mustPlacePaths = true
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
    def placeJourneyLocator(journeyDisplay, args, context)

    end

    ##
    # Places the JourneyLocation on the MapLayer according to the disposition
    # It places them in the call order, the last being on top. The postingRoute
    # is always on the top.
    #
    def placeJourneyLocation(journeyDisplay, disposition, context)
      time_now = Utils::Time.current
      onRoute = false
      isReporting = false
      currentLocation = nil
      if journeyDisplay.route.isReporting?
        isReporting = true
        isReported = true
        loc = getCurrentLocation()
        if loc
          currentLocation = GeoCalc.toGeoPoint(loc)
          currentDirection = loc.bearing
          points = GeoPathUtils.whereOnPath(journeyDisplay.paths[0], currentLocation, 60)
          first = nil
          for gp in points
            if gp.distance > 0
              if route.lastKnownDistance && gp.distance >= route.lastKnownDistance
                currentDirection = gp.bearing
                currentDistance = gp.distance
                onRoute = true
                break
              end
              first ||= gp
            end
          end
          onRoute ||= !first.nil?
          currentDirection ||= first.bearing if first
          currentDistance ||= first.distance if first
          currentTimediff = 0
        end
      end
      if currentLocation.nil?
        journeyDisplay.route.tap do |route|
          isReported = route.isReported?
          currentLocation = route.lastKnownLocation
          currentDirection = route.lastKnownDirection
          currentDistance = route.lastKnownDistance
          currentTimediff = route.lastKnownTimediff
          onRoute = route.onRoute
        end
      end
      startMeasure = journeyDisplay.route.getStartingMeasure(api.activeStartDisplayThreshold, time_now)
      if isReporting
        if currentLocation
          iconType = IconType::REPORTING
        else
          # We don't place a locator. May not have a valid location yet.
          return
        end
      elsif startMeasure < 1.0
        if startMeasure < 0
          iconType = IconType::TOO_EARLY
        else
          iconType = IconType::START
        end
        if currentLocation.nil?
          currentLocation = journeyDisplay.route.getStartingPoint
          currentDirection = 0
          currentDistance = 0
          currentTimediff = 0
        end
      else
        iconType = IconType::NORMAL
      end
      if currentLocation
        # < 0 means early
        # > 0 means late
        args = {
            :currentLocation => currentLocation,
            :currentDirection => currentDirection,
            :currentDistance => currentDistance,
            :currentTimediff => currentTimediff,
            :onRoute => onRoute,
            :isReporting => isReporting,
            :isReported => isReported,
            :startMeasure => startMeasure,
            :disposition => disposition,
            :iconType => iconType
        }
        PM.logger.info "#{self.class.name}#{self.__method__} #{args.inspect}"
        placeJourneyLocator(journeyDisplay, args, context)
      end
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
                if jd.isPathHighlighted?
                  placeJourneyLocation(jd, Disposition::HIGHLIGHT, context)
                else
                  placeJourneyLocation(jd, Disposition::NORMAL, context)
                end
                placed += 1
              end
            end
          end
        end
      end
      placeJourneyLocation(postingRoute, Disposition::NORMAL, context) if postingRoute
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
        if pat.isReady?
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
      journeyDisplays.each do |route|
        if route.isPathVisible?
          disposition = route.isPathHighlighted? ? Disposition::HIGHLIGHT : Disposition::NORMAL
          placeRoute(route, disposition, context)
        end
      end
    end

    def placeRoute(journeyDisplay, disposition, context)
      placePatterns(journeyDisplay.route.journeyPatterns, disposition, context)
    end

    def place(context)
      if ! doDraw
        return
      end
      state = journeyDisplayController.getCurrentState
      if state.state == VisualState::S_VEHICLE
        placeRoute(state.selectedRoute, Disposition::TRACK, context)
        placeJourneyLocation(state.selectedRoute, Disposition::TRACK, context)
      else
        placeRoutes(journeyDisplayController.journeyDisplays, context)
        placeJourneyLocations(journeyDisplayController.journeyDisplays, context)
      end
    end

  end
end