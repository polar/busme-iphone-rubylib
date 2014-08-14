module Platform
  class JourneyDisplayController
    attr_accessor :journeyBasket

    attr_accessor :journeyDisplays
    attr_accessor :journeyDisplayMap
    attr_accessor :onJourneyDisplayAddedListener
    attr_accessor :onJourneyDisplayRemovedListener

    def initialize(basket)
      self.journeyBasket = basket
      self.journeyDisplays = []
      self.journeyDisplayMap = {}
      journeyBasket.onJourneyAddedListener = self
      journeyBasket.onJourneyRemovedListener = self
    end

    def getJourneyDisplays
      journeyDisplays
    end

    # JourneyBasket.OnJourneyAddedListener
    def onJourneyAdded(basket, route)
      newRoute = JourneyDisplay.new(self, route)
      journeyDisplays << newRoute
      journeyDisplayMap[newRoute.route.id] = newRoute
      onJourneyDisplayAddedListener.onJourneyDisplayAdded(newRoute) if onJourneyDisplayAddedListener
      presentJourneyDisplay(newRoute)
    end

    # JourneyBasket.OnJourneyRemovedListener
    def onJourneyRemoved(basket, route)
      jd = journeyDisplayMap[route.id]
      if jd
        journeyDisplayMap.delete(route.id)
        journeyDisplays.delete(jd)
        onJourneyDisplayRemovedListener.onJourneyDisplayRemoved(jd) if onJourneyDisplayRemovedListener
        abandonJourneyDisplay(jd)
      end
    end

    def onCreate()
      self.journeyDisplays = []
      self.journeyDisplayMap = {}
    end

    #
    # This is called from the JourneySyncRequestProcessor and is run on
    # the background thread. The ProgressListener should be posting events
    # to the UI Thread.
    #
    def sync(nameids)  # TODO: Extend
      progressListener = nil
      ioListener = nil
      journeyBasket.sync(nameids, progressListener, ioListener)
    end

    def onLocationUpdate(route, locations)
      jd = journeyDisplayMap[route.id]
    end

    def presentJourneyDisplay(journey_display)
      #raise "NotImplemented"
    end

    def abandonJourneyDisplay(journey_display)
      #raise "NotImplemented"
    end

  end
end