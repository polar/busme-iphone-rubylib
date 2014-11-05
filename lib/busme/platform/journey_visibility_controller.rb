module Platform
  class VisualState
    attr_accessor :state
    attr_accessor :nearBy
    attr_accessor :onlyActive
    attr_accessor :selectedRoute
    attr_accessor :selectedRouteCode
    attr_accessor :selectedRouteCodes
    attr_accessor :selectedRoutes
    attr_accessor :onlySelected
    attr_accessor :selectedLocations

    S_ALL = 1
    S_ROUTE = 2
    S_VEHICLE = 3

    def initialize
      self.state = S_ALL
      self.nearBy = false
      self.onlyActive = false
      # For S_VEHICLE
      self.selectedRoute = nil
      # For S_ROUTE
      self.selectedRouteCode = nil

      # For S_ALL, S_ROUTE
      self.selectedRoutes = Set.new
      self.selectedLocations = Set.new

      # For S_ALL
      self.onlySelected = false
      # When a location selects routes, we set the selected route codes.
      self.selectedRouteCodes = Set.new
    end
  end

  class JourneyVisibilityController
    attr_accessor :api
    attr_accessor :journeyDisplayController

    attr_accessor :nearByDistance

    attr_accessor :stateStack

    def initialize(api, controller)
      self.api = api
      self.journeyDisplayController = controller
      self.stateStack = Utils::Stack.new
      self.stateStack.push(VisualState.new)
      controller.onJourneyDisplayAddedListener = self
      controller.onJourneyDisplayRemovedListener = self
    end

    def journeyDisplays
      journeyDisplayController.getJourneyDisplays
    end

    def getCurrentState
      stateStack.peek()
    end

    def setNearByState(nearby)
      puts( "setNearByState")
      newState = VisualState.new
      newState.nearBy = nearby
      newState.onlyActive = stateStack.peek().onlyActive
      self.stateStack = Utils::Stack.new
      stateStack.push(newState)
      setVisibility(newState)
    end

    def setOnlyActiveState(active)
      puts( "setOnlyActive")
      newState = VisualState.new
      newState.onlyActive = active
      newState.nearBy = stateStack.peek().nearBy
      self.stateStack = Utils::Stack.new
      stateStack.push(newState)
      setVisibility(newState)
    end

    #
    # Called from JourneyDisplayController
    #
    def onJourneyDisplayAdded(display)
      # all ready added to the journeyDisplayController.getJourneyDisplays
      state = stateStack.peek
      if addJourneyToState(state, display)
        setVisibilityJourneyDisplay(state, display)
      else
        display.pathVisible = display.nameVisible = false
      end
    end

    #
    # Called from JourneyDisplayController
    #
    def onJourneyDisplayRemoved(display)
      # all ready removed from the journeyDisplayController.getJourneyDisplays
      state = stateStack.peek
      display.pathVisible = display.nameVisible = false
      while stateStack.size > 0 && removeJourneyDisplayFromState(state, display)
        state = stateStack.pop
      end
      if stateStack.empty?
        stateStack.push(VisualState.new)
      end
      setVisibility(state)
    end

    #
    # Should be called when the current location is updated from the
    # device. This handles "nearby" visibilities.
    #
    # Returns true if some displays are to disappear, or come back.
    #
    def onCurrentLocationChanged(point)
      changed = false
      self.currentLocation = point
      state = stateStack.peek
      if state.nearBy
        case state.state
          when VisualState::S_ALL, VisualState::S_ROUTE
            for display in getJourneyDisplays do
              isNearBy = false
              for path in display.route.paths do
                if GeoPathUtils.isOnPath(path, point, nearByDistance)
                  isNearBy = true
                  changed ||= setVisibilityJourneyDisplay(state, display)
                  break
                end
              end
              if !isNearBy
                changed ||= display.nameVisible
                changed ||= display.pathVisible
                display.nameVisible = display.pathVisible = false
              end
            end
        end
      end
      changed
    end

    #
    # A Command issued by User
    #
    def goBack
      if stateStack.size > 1
        stateStack.pop
      end
      setVisibility(stateStack.peek)
    end

    #
    # Called by User selecting a particular location for filtering.
    #
    # Returns true if it changed the selection and added a new Visual State
    #
    def onLocationSelected(geoPoint, buffer)
      atLeastOneSelected = false
      selected = []
      unselected = []
      for display in journeyDisplayController.getJourneyDisplays do
        if display.pathVisible
          isSelected = false
          for path in display.route.paths do
            if GeoPathUtils.isOnPath(path, geoPoint, buffer)
              isSelected = true
            end

          end
          if isSelected
            atLeastOneSelected = true
            selected << display
          else
            unselected << display
          end
        end
      end
      if atLeastOneSelected
        newState = VisualState.new
        newState.state = stateStack.peek.state
        newState.nearBy = stateStack.peek.nearBy
        newState.onlyActive = stateStack.peek.onlyActive
        newState.onlySelected = true
        newState.selectedLocations = stateStack.peek.selectedLocations.dup
        newState.selectedLocations << geoPoint
        newState.selectedRoutes =  stateStack.peek.selectedRoutes.dup
        newState.selectedRoutes.merge(selected)
        newState.selectedRoutes.subtract(unselected)
        newState.selectedRouteCodes.merge(newState.selectedRoutes.map{|x| x.route.code})
        stateStack.push(newState)
        setVisibility(newState)
        return true
      end
      return false
    end

    def onSelectionChanged(selected, unselected, geoPoint)
      newState = VisualState.new
      newState.state = stateStack.peek.state
      newState.nearBy = stateStack.peek.nearBy
      newState.onlyActive = stateStack.peek.onlyActive
      newState.onlySelected = true
      newState.selectedLocations = stateStack.peek.selectedLocations.dup
      newState.selectedLocations << geoPoint
      newState.selectedRoutes =  stateStack.peek.selectedRoutes.dup
      newState.selectedRoutes.merge(selected)
      newState.selectedRoutes.subtract(unselected)
      newState.selectedRouteCodes.merge(newState.selectedRoutes.map{|x| x.route.code})
      stateStack.push(newState)
      setVisibility(newState)
    end

    #
    # Called when User selects a vehicle to track
    # Moves to the S_VEHICLE state
    #
    def onVehicleSelected(display)
      state = stateStack.peek
      if state.state == VisualState::S_VEHICLE
        if state.selectedRoute == display
          return false
        else
          stateStack.pop
        end
      end
      newState = VisualState.new
      newState.state = VisualState::S_VEHICLE
      newState.nearBy = state.nearBy
      newState.onlyActive = state.onlyActive
      newState.selectedRoute = display
      stateStack.push(newState)
      setVisibility(newState)
      return true
    end

    #
    # Called when User selects a route for filtering
    # Moves to the S_ROUTE state
    #
    def onRouteCodeSelected(code)
      state = stateStack.peek
      if state.state == VisualState::S_ROUTE
        if state.selectedRouteCode == code
          return false
        else
          stateStack.pop
        end
      end
      newState = VisualState.new
      newState.state = VisualState::S_ROUTE
      newState.nearBy = state.nearBy
      newState.onlyActive = state.onlyActive
      newState.selectedRouteCode = code
      stateStack.push(newState)
      setVisibility(newState)
      return true
    end

    protected

    # Returns true if nothing would be visible from the state.
    def addJourneyToState(state, display)
      case state.state
        when VisualState::S_VEHICLE
          if state.selectedRoute.route.id == display.route.id
            state.selectedRoute = display
            return true
          end
        when VisualState::S_ROUTE
          if ! state.selectedRoutes.include?(display)
            if state.selectedRouteCode == display.route.code
              if state.selectedLocations.empty?
                state.selectedRoutes.add(display)
                return true
              else
                for point in state.selectedLocations do
                  paths = display.route.paths
                  for path in paths do
                    if GeoPathUtils.isOnPath(path, point, 60)
                      state.selectedRoutes.add(display)
                      return true
                    end
                  end
                end
              end
            end
          end
          return false
        when VisualState::S_ALL
          if state.onlySelected
            if ! state.selectedRoutes.include?(display)
              if !state.selectedRouteCodes.empty?
                state.selectedRoutes.add(display)
                return true
              else
                for point in state.selectedLocations do
                  paths = display.route.paths
                  for path in paths do
                    if GeoPathUtils.isOnPath(path, point, 60)
                      state.selectedRoutes.add(display)
                      return true
                    end
                  end
                end
              end
            end
          else
            return true
          end
          return false
        else
          raise "Bad Visual State"
      end
      return false
    end

    # Returns true if nothing would be visible from the state.
    def removeJourneyDisplayFromState(state, display)
      case state.state
        when VisualState::S_VEHICLE
          state.selectedRoutes.delete(display)
          if state.selectedRoutes.empty?
            return true
          end
        when VisualState::S_ROUTE
          state.selectedRoutes.delete(display)
          if display.route.isRouteDefinition?
            if state.selectedRouteCode == display.route.code
              return true
            end
            if state.onlySelected && state.selectedRoutes.empty?
              return true
            end
          end
        when VisualState::S_ALL
          state.selectedRoutes.delete(display)
          if display.route.isRouteDefinition?
            state.selectedRouteCodes.delete(display.route.code)
          end
          if state.onlySelected && state.selectedRoutes.empty? && state.selectedRouteCodes.empty?
            return true
          end
        else
          raise "Bad VisualState"
      end
      return false
    end

    def setVisibility(state)
      case state.state
        when VisualState::S_ALL, VisualState::S_ROUTE
          for display in journeyDisplays
            setVisibilityJourneyDisplay(state, display)
          end
        when VisualState::S_VEHICLE
          for display in journeyDisplays
            if state.selectedRoute == display
              if display.route.isJourney?
                display.nameVisible = true
                display.pathVisible = true
                routeDisplay = display.getRouteDefinition
                if routeDisplay
                  routeDisplay.nameVisible = true
                  routeDisplay.pathVisible = false
                end
              end
            else
              display.pathVisible = display.nameVisible = false
            end
          end
      end
    end

    # Returns true if visibility of display changes.
    def setVisibilityJourneyDisplay(state, display)
      case state.state
        when VisualState::S_ALL
          forS_ALL(state, display)
        when VisualState::S_ROUTE
          forS_ROUTE(state, display)
        when VisualState::S_VEHICLE
          forS_VEHICLE(state, display)
      end
      true
    end

    # Returns true if visibility of display changes.
    def forS_ALL(state, display)
      nameVisible = display.nameVisible
      pathVisible = display.pathVisible
      if !state.onlySelected ||
          state.selectedRoutes.include?(display) ||
          state.selectedRouteCodes.include?(display.route.code)
        if display.route.isRouteDefinition?
          if state.onlyActive
            display.pathVisible = display.nameVisible = display.hasActiveJourneys?
          else
            display.pathVisible = display.nameVisible = true
          end
        elsif display.isActive?
          # only paths of active routes (with current locations)
          display.nameVisible = false  # Don't show he bus name
          display.pathVisible = true
        else
          if display.route.timeless
            display.nameVisible = false
            display.pathVisible = true
          else
            display.nameVisible = false
            display.pathVisible = false
          end
        end
      else
        display.pathVisible = display.nameVisible = false
      end
      changed = display.pathVisible != pathVisible || display.nameVisible != nameVisible
    end

    # Returns true if visibility of display changes.
    def forS_ROUTE(state, display)
      nameVisible = display.nameVisible
      pathVisible = display.pathVisible
      if state.selectedRouteCode == display.route.code
        if display.route.isRouteDefinition?
          if state.onlyActive
            display.pathVisible = display.nameVisible = display.hasActiveJourneys?
          else
            display.pathVisible = display.nameVisible = true
          end
        elsif display.isActive?
          display.pathVisible = display.nameVisible = true
        else
          if display.route.timeless
            display.pathVisible = display.nameVisible = true
          else
            display.pathVisible = display.nameVisible = false
          end
        end
      else
        display.pathVisible = display.nameVisible = false
      end
      changed = display.pathVisible != pathVisible || display.nameVisible != nameVisible
    end

    def forS_VEHICLE(state, display)
      nameVisible = display.nameVisible
      pathVisible = display.pathVisible
      if state.selectedRoute == display
        display.pathVisible = display.nameVisible = true
      end
      changed = display.pathVisible != pathVisible || display.nameVisible != nameVisible
    end

  end
end