module Platform
  class JourneyDisplaySelectionController
    includes JourneyDisplayUtility
    attr_accessor :api
    attr_accessor :journeyDisplayController
    attr_accessor :journeyDisplayVisibilityController
    attr_accessor :journeyPostingController
    attr_accessor :trackingJourneyDisplay
    attr_accessor :highlightJourneyDisplay
    attr_accessor :postingJourneyDisplay

    def initialize(api, journeyDisplayController, journeyDisplayVisibilityController)
      self.api = api
      self.journeyDisplayController = journeyDisplayController
      self.journeyDisplayVisibilityController = journeyDisplayVisibilityController
    end

    def selectTrackingJourney(journeyDisplay)
      if journeyDisplayController.journeyDisplays.include?(journeyDisplay)
        if self.trackingJourneyDisplay
          self.trackingJourneyDisplay.tracking = false
        end
        self.trackingJourneyDisplay = journeyDisplay
        journeyDisplay.tracking = true
      end
    end

    def selectHighlightJourney(journeyDisplay)
      if journeyDisplayController.journeyDisplays.include?(journeyDisplay)
        if self.highlightJourneyDisplay
          self.highlightJourneyDisplay.pathHighlighted = false
        end
        self.trackingJourneyDisplay = journeyDisplay
        journeyDisplay.pathHighlighted = true
      end
    end

    def onSelectForPosting(screenPoint, screenRect, touchRect, zoomLevel)
      projection = Utils::ScreenPathUtils::Projection.new(zoomLevel, screenRect)
      jds = journeyDisplayController.journeyDisplays
      jd = hitsRouteLocator(jds, screenPoint, touchRect, projection)
      if jd
        if jd.isActive?
          self.postingJourneyDisplay = jd
        end
      end
    end


    def onSelectionChanged(selected, unselected, touchGP)
      journeyDisplayVisibilityController.onSelectionChanged(selected, unselected, touchGP)
    end
  end
end