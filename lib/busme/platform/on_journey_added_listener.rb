module Platform
  class OnJourneyAddedListener
    def onJourneyDisplayAddedPre(journey_basket_controller, journey_basket, journey_display)
      raise "NotImplemented"
    end
    def onJourneyDisplayAddedPost(journey_basket_controller, journey_basket, journey_display)
      raise "NotImplemented"
    end
  end
end