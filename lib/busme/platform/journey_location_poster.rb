module Platform
  class JourneyEventData
    attr_accessor :route
    attr_accessor :role
    attr_accessor :action
    attr_accessor :location
    attr_accessor :reason

    A_ON_ROUTE_POSTING = 1
    A_AT_ROUTE_START   = 2
    A_OFF_ROUTE        = 3
    A_ON_ROUTE         = 4
    A_UPDATE_ROUTE     = 5
    A_AT_ROUTE_END     = 6
    A_ON_ROUTE_DONE    = 7

    R_NORMAL        = 1
    R_FORCED        = 2
    R_DISABLED      = 3
    R_SERVICE       = 4
    R_OFF_ROUTE     = 5
    R_NOT_AVAILABLE = 6
  end

  class JourneyLocationPoster
    include Api::BuspassEventListener

    attr_accessor :api
    attr_accessor :postingRoute
    attr_accessor :postingPathPoints
    attr_accessor :startPoint
    attr_accessor :endPoint
    attr_accessor :postingRole
    attr_accessor :offRouteCount
    attr_accessor :alreadyPosting
    attr_accessor :alreadyStarted
    attr_accessor :alreadyFinished

    def initialize(api)
      self.api = api

      api.uiEvents.registerForEvent("LocationChanged", self)
      api.uiEvents.registerForEvent("LocationProviderDisabled", self)
      api.uiEvents.registerForEvent("LocationProviderEnabled", self)

      api.bgEvents.registerForEvent("JourneyStartPosting", self)
      api.bgEvents.registerForEvent("JourneyStopPosting", self)
      api.bgEvents.registerForEvent("JourneyRemoved", self)
    end

    def reset(route, role)
      self.postingRoute = route
      self.postingRole = role
      self.alreadyPosting = false
      self.alreadyFinished = false
      self.alreadyStarted = false
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        # Foreground Thread
        when "LocationProviderEnabled"
          onProviderEnabled(eventData)
        when "LocationProviderDisabled"
          onProviderDisabled(eventdata)
        when "LocationChanged"
          onLocationChanged(eventData.location)

        # Background Thread
        when "JourneyStartPosting"
          onJourneyStartPosting(eventData)
        when "JourneyStopPosting"
          onJourneyStopPosting(eventData)
        when "JourneyRemoved"
          onJourneyRemoved(eventData)
      end
    end

    def startPosting(route, role)
      self.postingRoute = route
      self.postingRole = role
      self.postingPathPoints = route.paths.first
      self.startPoint = postingPathPoints.first
      self.endPoint = postingPathPoints.last
    end

    def endPosting(reason = JourneyEventData::R_FORCED)
      if postingRoute
        postingRoute.reporting = false
        notifyOnRouteDone(reason)
        reset(nil, nil)
      end
    end

    #
    # Process the location and determine what do do.
    # Notify the Foreground of OnRoutePosting, AtRouteStart, UpdateRoute, AtRouteEnd
    #
    # TODO: Determine Off Route stuff.
    def processLocation(location)
      if postingRoute
        if ! alreadyPosting
          notifyOnRoutePosting(location)
          self.alreadyPosting = true
        end

        point = GeoCalc.toGeoPoint(location)

        # TODO: The StartRoute notification might need some work
        if postingRoute.lastKnownLocation.nil? &&
          GeoCalc.getGeoDistance(point, startPoint) < api.offRouteDistanceThreshold
          if location.speed > 5 && !alreadyStarted
            notifyAtRouteStart(location)
            self.alreadyStarted = true
          end
        end

        postLocation(location)
        notifyUpdateRoute(location)

        # TODO: OffRoute Notification
        # TODO: OnRoute Notification

        # TODO: The EndRoute Notification might need some work
        if GeoCalc.getGeoDistance(point, endPoint) < api.offRouteDistanceThreshold
          if location.speed > 0 && !alreadyFinished
            notifyAtRouteEnd(location)
            self.alreadyFinished = true
          end
        end
      end
    end

    #
    # This method creates a background event "JourneyLocationPost", which should be
    # picked up by the JourneyPostingController, which will post the location.
    # Issues.
    #   The user should be logged in by now.
    #
    def postLocation(location)
      api.bgEvents.postEvent("JourneyLocationPost",
                             JourneyLocationEventData.new(postingRoute, location, postingRole))
    end


    #
    # Background Event for "JourneyStartPosting"
    #
    def onJourneyStartPosting(eventData)
      if postingRoute
        endPosting(JourneyEventData::R_FORCED)
      end
      startPosting(eventData.route, eventData.role)
    end

    #
    # Background Event for "JourneyStopPosting"
    #
    def onJourneyStopPosting(eventData)
      if postingRoute
        endPosting(eventData.reason)
      end
    end

    #
    # Background Event for "JourneyRemoved"
    #
    def onJourneyRemoved(eventData)
      if eventData.id == postingRoute
        endPosting(JourneyEventData::R_NORMAL)
      end
    end

    #
    # Foreground Event for "LocationChanged"
    #
    def onLocationChanged(eventData)
      processLocation(eventData.location)
    end

    #
    # Foreground Event for "LocationProviderEnabled"
    #
    def onProviderEnabled(eventData)
    end

    #
    # Foreground Event for "LocationProviderDisabled"
    #
    def onProviderDisabled(eventData)
      endPosting(JourneyEventData::R_DISABLED)
    end

    def notifyOnRoutePosting(location)
      eventData = JourneyEventData.new
      eventData.route = postingRoute
      eventData.role = postingRole
      eventData.location = location
      eventData.action = JourneyEventData::A_ON_ROUTE_POSTING
      api.uiEvents.postEvent("JourneyEvent", eventData)
    end

    def notifyAtRouteStart(loc)
      eventData = JourneyEventData.new
      eventData.route = postingRoute
      eventData.role = postingRole
      eventData.location = loc
      eventData.action = JourneyEventData::A_AT_ROUTE_START
      api.uiEvents.postEvent("JourneyEvent", eventData)
    end

    def notifyOnRoute(loc)
      eventData = JourneyEventData.new
      eventData.route = postingRoute
      eventData.role = postingRole
      eventData.location = loc
      eventData.action = JourneyEventData::A_ON_ROUTE
      api.uiEvents.postEvent("JourneyEvent", eventData)
    end

    def notifyUpdateRoute(loc)
      eventData = JourneyEventData.new
      eventData.route = postingRoute
      eventData.role = postingRole
      eventData.location = loc
      eventData.action = JourneyEventData::A_UPDATE_ROUTE
      api.uiEvents.postEvent("JourneyEvent", eventData)
    end

    def notifyOffRoute(loc)
      eventData = JourneyEventData.new
      eventData.route = postingRoute
      eventData.role = postingRole
      eventData.location = loc
      eventData.action = JourneyEventData::A_OFF_ROUTE
      api.uiEvents.postEvent("JourneyEvent", eventData)
    end

    def notifyAtRouteEnd(location)
      eventData = JourneyEventData.new
      eventData.route = postingRoute
      eventData.role = postingRole
      eventData.location = location
      eventData.action = JourneyEventData::A_AT_ROUTE_END
      api.uiEvents.postEvent("JourneyEvent", eventData)
    end

    def notifyOnRouteDone(reason)
      eventData = JourneyEventData.new
      eventData.route = postingRoute
      eventData.role = postingRole
      eventData.reason = reason
      eventData.action = JourneyEventData::A_ON_ROUTE_DONE
      api.uiEvents.postEvent("JourneyEvent", eventData)
      reset(nil, nil)
    end

  end
end