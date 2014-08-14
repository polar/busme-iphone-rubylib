module Platform

  ##
  # This class contains the logical bits of the display for a route/journey.
  # That is, if the path and name should be visible. If it's a route, the
  # journeys that belong to it, etc.
  class JourneyDisplay
    attr_accessor :route

    attr_accessor :nameVisible
    attr_accessor :nameHighlighted
    attr_accessor :pathVisible
    attr_accessor :pathHighlighted
    attr_accessor :tracking
    attr_accessor :hiddenListener
    attr_accessor :journeyDisplayController

    def initialize(controller, route)
      self.route = route
      self.journeyDisplayController = controller
      self.nameVisible = true
      self.nameHighlighted = false
      self.pathVisible = true
      self.pathHighlighted = false
      self.tracking = false
    end

    ROUTE_ICON = 1
    ROUTE_ICON_ACTIVE = 2
    PURPLE_DOT_ICON = 3
    BLUE_CIRCLE_ICON = 4
    GREEN_ARROW_ICON = 5
    BLUE_ARROW_ICON = 6
    BUS_ICON_ACTIVE = 7

    def isStarting?
      route.isStarting?
    end
    def isFinished?
      route.isFinished?
    end
    def isActive?
      route.isActiveJourney? && !isFinished? || isStarting?
    end
    def isNameVisible?
      nameVisible && ! route.isFinished?
    end
    def isPathVisible
      pathVisible
    end
    def isPathHidden
      !pathVisible
    end
    def pathVisible=(visible)
      @pathVisible = visible
      notifyHiddenListener(!visible)
    end
    def pathHidden=(hidden)
      @pathVisible = !hidden
      notifyHiddenListener(hidden)
    end
    def isTracking?
      tracking
    end
    def notifyHiddenListener(hidden)
      hiddenListener.onHidden(self, hidden) if hiddenListener
    end

    def getIcon
      if route.isRouteDefinition?
        if hasActiveJourneys?
          ROUTE_ICON_ACTIVE
        else
          ROUTE_ICON
        end
      else
        if route.isStartingJourney?
          PURPLE_DOT_ICON
        elsif route.isNotYetStartingJourney?
          BLUE_CIRCLE_ICON
        elsif isTracking?
          GREEN_ARROW_ICON
        elsif route.isActiveJourney?
          BLUE_ARROW_ICON
        else
          BUS_ICON_ACTIVE
        end
      end
    end

    def getRouteDefinition
      if journeyDisplayController.getJourneyDisplays.include?(@routeDefinition)
        return @routeDefinition
      end
      if route.isJourney?
        for jd in journeyDisplayController.getJourneyDisplays
          if jd.route.isRouteDefinition?
            if jd.route.code == route.code
              @routeDefinition = jd
            end
          end
        end
      end
      @routeDefinition
    end

    def hasActiveJourneys?
      if route.isRouteDefinition?
        for jd in journeyDisplayController.getJourneyDisplays
          if jd.isActive?
            if jd.route.code == route.code
              return true
            end
          end
        end
      end
      return false
    end

    def activeJourneys
      jds = []
      if route.isRouteDefinition?
        for jd in journeyDisplayController.getJourneyDisplays
          if jd.isActive?
            if jd.route.code == route.code
              jds << jd
            end
          end
        end
      end
      jds
    end
  end

end