module Platform
  class OnJourneyRemovedListener
    def onJourneyDisplayRemovedPre(journey_basket_controller, journey_basket, journey_display)
      raise "NotImplemented"
    end
    def onJourneyDisplayRemovedPost(journey_basket_controller, journey_basket, journey_display)
      raise "NotImplemented"
    end
  end
end