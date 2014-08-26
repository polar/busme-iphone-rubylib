module Platform
  class JourneyDisplaySelectionController
    attr_accessor :api
    attr_accessor :journeyDisplayController
    attr_accessor :journeyDisplayUtility
    attr_accessor :journeyDisplayVisibilityController
    attr_accessor :journeyPostingController
    attr_accessor :trackingJourneyDisplay

    def initialize(api, journeyDisplayController, journeyDisplayVisibilityController)
      self.api = api
      self.journeyDisplayController = journeyDisplayController
      self.journeyDisplayVisibilityController = journeyDisplayVisibilityController
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

    def onSelectForPosting(screenPoint, screenRect, touchRect, zoomLevel)
      projection = Utils::ScreenPathUtils::Projection.new(zoomLevel, screenRect)
      jds = journeyDisplayController.journeyDisplays
      jd = journeyDisplayUtility.hitsLocator(jds, screenPoint, touchRect, projection)
      if jd
        if jd.isActive?
          evenData = JourneyEventData.new
          eventData.postingRoute
          eventData.postingRole
          api.bgEvents.postEvent("JourneyStartPosting", eventData)
        end
      end
      journeyDisplayVisbilityController
    end
  end
end