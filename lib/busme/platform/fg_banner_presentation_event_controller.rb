module Platform
  ##
  # This class merely handles event processing for the BannerPresentationController
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
          displayBanner(eventData)
        when "BannerPreset:Dismiss"
          dismissBanner(eventData)
      end
    end

    def displayBanner(eventData)
      raise "NotImplemented"
    end

    def dismissBanner(eventData)
      raise "NotImplemented"
    end
  end

end