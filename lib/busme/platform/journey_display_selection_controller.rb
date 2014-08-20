module Platform
  class JourneyDisplaySelectionController
    attr_accessor :api
    attr_accessor :journeyDisplayController
    attr_accessor :trackingJourneyDisplay

    def initialize(api, journeyDisplayController)
      self.api = api
      self.journeyDisplayController = journeyDisplayController
      api.uiEvents.registerForEvent("Map:SelectionChanged", self)
    end

    def selectTrackingJourney(journeyDisplay)
      if journeyDisplayController.journeyDisplays.include?(journeyDisplay)
        self.trackingJourneyDisplay = journeyDisplay
        journeyDisplay.tracking = true
      else
        self.trackingJourneyDisplay = journeyDisplay
      end
    end
  end
end