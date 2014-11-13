module Platform
  #
  # This class handles the Foreground Thread's handling of messages
  class FGBannerController
    include Api::BuspassEventListener
    include BannerEventConstants
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("BannerEvent", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a? BannerEventData
        case eventData.state
          when S_PRESENT
            onPresent(eventData)
          when S_RESOLVED
            onResolved(eventData)
          when S_ERROR
            onError(eventData)
          when S_DONE
            onDone(eventData)
          else
        end
      end
    end

    def presentBanner(eventData)
    end

    def dismissBanner(eventData)
      # Make the banner slide out of view

    end

    def onPresent(eventData)
      presentBanner(eventData)
      # There are no Foreground or Background Events issued here.
    end

    # This gets called from the UI when the user clicks on the banner.
    def onGo(eventData)
      eventData.bannerForeground.onInquired(eventData, R_GO)
      # It triggers a background event to go get the the clickthru URL
      # and that issues a ui BannerEvent with S_RESOLVED or S_ERROR.
    end

    def onResolved(eventData)
      dismissBanner(eventData)
      # Fire up the web page to the eventData.thruURL
      # Through issuing another UI event.
    end

    def onError(eventData)
      dismissBanner(eventData)
    end

    def onDone(eventData)
      dismissBanner(eventData)
    end

  end
end
