module Platform
  ##
  # This class merely handles event processing for the BannerPresentationController
  # It is extended for the particular UI or testing environment and will be added assigned to
  # masterController.fgBannerPresentationEventController.
  #
  # The masterController.bannerPresentationController.roll spawns these events.
  #
  class FG_BannerPresentationEventController
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("BannerPresent:Display", self)
      api.uiEvents.registerForEvent("BannerPresent:Dismiss", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "BannerPresent:Display"
          displayBanner(eventData.banner_info)
        when "BannerPresent:Dismiss"
          dismissBanner(eventData.banner_info)
      end
    end

    def displayBanner(bannerInfo)
      raise "NotImplemented"
    end

    def dismissBanner(bannerInfo)
      raise "NotImplemented"
    end
  end

end