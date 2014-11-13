module Platform
  class JourneyBasket
    module ProgressListener
      def onSyncStart(); raise "NotImplemented"; end
      def onSyncEnd(nRoutes); raise "NotImplemented"; end
      def onRouteStart(iRoute); raise "NotImplemented"; end
      def onRouteEnd(iRoute); raise "NotImplemented"; end
      def onDone(); raise "NotImplemented"; end
    end

    module OnIOErrorListener
      def onIOError(journey_basket, io_exception); raise "NotImplemented"; end
    end
    module OnJourneyAddedListener
      def onJourneyAdded(journey_basket, route); raise "NotImplemented"; end
    end
    module OnJourneyRemovedListener
      def onJourneyRemoved(journey_basket, route); raise "NotImplemented"; end
    end
    module OnBasketUpdateListener
      def onUpdateBasket(journey_basket); raise "NotImplemented"; end
    end

    attr_accessor :onIOErrorListener
    attr_accessor :onJourneyAddedListener
    attr_accessor :onJourneyRemovedListener
    attr_accessor :onBasketUpdateListener

    attr_accessor :activityAPI
    attr_accessor :journeys
    attr_accessor :journeyMap
    attr_accessor :journeyStore

    def initialize(api, store)
      self.activityAPI = api
      self.journeyStore = store
      self.journeys = []
      self.journeyMap = {}
    end

    def getRoute(id)
      return journeyMap[id]
    end

    def getAllRoutes
      return journeys.dup
    end

    def getAllJourneys
      journeys.select {|x| x.isJourney?}
    end

    def getAllActiveJourneys
      journeys.select {|x| x.isActiveJourney? }
    end

    def empty
      copy_journeys = journeys.dup
      setJourneys([])
      for route in copy_journeys
        notifyOnJourneyRemovedListener(route)
      end
      notifyOnBasketUpdateListener
    end

    def sync(journeyids, progressListener, onIOErrorListener)
      copy_journeys = journeys.dup
      addedJourneys = []
      removedJourneys = []
      keepJourneys = []
      newJourneys = []
      index = 0
      for nameid in journeyids
        if progressListener
          progressListener.onRouteStart(index)
        end
        if nameid
          addJourney = true
          for route in copy_journeys
            if route.id == nameid.id
              if route.version < nameid.version
                addJourney = true
                journeyStore.removeJourney(route.id)
              else
                addJourney = false
              end
              route.updateStartTimes(nameid)
              break
            end
          end
        end
        if addJourney
          route = retrieveRouteJourney(nameid)
          if route
            if route.isJourney?
              measure = route.getStartingMeasure
            end
            addedJourneys << route
          end
        end

        if progressListener
          progressListener.onRouteEnd(index)
        end
        index += 1
      end
      for route in copy_journeys
        removeJourney = true
        for nameid in journeyids
          if route.id == nameid.id
            if route.version != nameid.version
              removeJourney = true
            else
              removeJourney = false
            end
            break
          end
        end
        if removeJourney
          removedJourneys << route
        else
          if route
            if route.isJourney?
              measure = route.getStartingMeasure
            end
            keepJourneys << route
          end
        end
      end
      newJourneys += keepJourneys
      newJourneys += addedJourneys
      setJourneys(newJourneys)
      for route in removedJourneys
        notifyOnJourneyRemovedListener(route)
      end
      for route in addedJourneys
       #puts "JourneyBasket. onJourneyAdded #{route.name} #{route.direction}"
        notifyOnJourneyAddedListener(route)
      end
      notifyOnBasketUpdateListener()
    end

    protected


    def retrieveRouteJourney(nameid)
      route = journeyStore.getJourney(nameid.id)
      if route.nil?
        route = retrieveAndStoreRoute(nameid)
      end
      if route
        route.busAPI = activityAPI
        if route.isJourney?
          pattern = route.getJourneyPattern(route.patternid)
          if pattern.nil?
            retrieveAndStoreJourneyPattern(route.patternid)
          end
        elsif route.isRouteDefinition?
          for pid in route.patternids
            pattern = route.getJourneyPattern(pid)
            if pattern.nil?
              retrieveAndStoreJourneyPattern(pid)
            end
          end
        end
      end
      route
    end

    def retrieveAndStoreJourneyPattern(pid)
      pattern = retrieveJourneyPattern(pid)
      if pattern
        journeyStore.storePattern(pattern)
      end
      pattern
    rescue IOError => boom
      pattern
    end

    def retrieveAndStoreRoute(nameid)
      route = retrieveRoute(nameid)
      if route
        journeyStore.storeJourney(route)
      end
      route
    rescue IOError => boom
      route
    end

    def retrieveRoute(nameid)
      activityAPI.getRouteDefinition(nameid)
    end

    def retrieveJourneyPattern(id)
      activityAPI.getJourneyPattern(id)
    end

    def setJourneys(js)
      self.journeys = js
      updateJourneyMap
     #puts "JourneyBasket:setJourneys:"
      self.journeys.each {|x| puts "#{x.name} #{x.id}"}
    end

    def updateJourneyMap
      self.journeyMap = {}
      journeys.each{|x| journeyMap[x.id] = x}
    end

    def notifyOnIOErrorListener(io_error)
      onIOErrorListener.onIOError(self, io_error) if onIOErrorListener
    end

    def notifyOnJourneyAddedListener(route)
      onJourneyAddedListener.onJourneyAdded(self, route) if onJourneyAddedListener
    end

    def notifyOnJourneyRemovedListener(route)
      onJourneyRemovedListener.onJourneyRemoved(self, route) if onJourneyRemovedListener
    end

    def notifyOnBasketUpdateListener
      onBasketUpdateListener.onUpdateBasket(self) if onBasketUpdateListener
    end

  end
end