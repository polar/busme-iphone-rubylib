module Platform

  class JourneySelectionEventData
    attr_accessor :uiData
    attr_accessor :location
    attr_accessor :journeyDisplays
    attr_accessor :selectedJourney
  end

  ##
  # The purpose of this controller is to handle the menus selections
  # for posting to a bunch of selected journeys.
  #
  class JourneySelectionPostingController
    attr_accessor :api
    attr_accessor :journeyVisibilityController

    def initialize(api, journeyVisibilityController)
      self.api = api
      self.journeyVisibilityController = journeyVisibilityController
      api.uiEvents.registerForEvent("JourneyPost:selectJourneys", self)
      api.uiEvents.registerForEvent("JourneyPost:startPosting", self)
      api.uiEvents.registerForEvent("JourneyPost:stopPosting", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "JourneyPost:selectJourneys"
          onSelectJourneys(eventData)
        when "JourneyPost:startPosting"
          onStartPosting(eventData)
        when "JourneyPost:stopPosting"
          onStopPosting(eventData)
      end
    end

    def selectJourneys(loc)
      journeyDisplays = journeyVisibilityController.selectJourneysFromPoint(loc, 60)
    end

    def onSelectJourneys(eventData)
      loc = eventData.location
      eventData.journeyDisplays = selectJourneys(loc)
      api.uiEvents.postEvent("JourneyPost:SelectJourneys:return", eventData)
    end

    def startPosting(selectedRoute, role)
      evd = JourneyEventData.new
      evd.route = selectedRoute
      evd.role = role
      api.bgEvents.postEvent("JourneyStartPosting", evd)
    end

    def onStartPosting(eventData)
      startPosting(eventData.selectedJourney.route, eventData.role)
    end

    def stopPosting
      api.bgEvents.postEvent("JourneyStopPosting")
    end

    def onStopPosting(eventData)
      stopPosting
    end
  end
end