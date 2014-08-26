module Platform
  ##
  # This class handles the base implementation to be extended by the
  # actual UI for onNotifyStart, which is supposed to take the
  # go URL and bring up a browser, or browser window containing
  # the page for the thruURL.
  #
  class FG_BannerMessageEventController < RequestController
    include BannerMessageConstants
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("BannerMessage", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "BannerMessage"
          onRequestState(eventData)
      end
    end

    def onStart(requestState)
      requestState.state = S_INQUIRE_START
      onInquireStart(requestState)
    end

    def onInquireStart(requestState)
      # Normally put up dialog, but does not do anything for a banner
      requestState.state = S_INQUIRE_IN_PROGRESS
      requestState.state = S_INQUIRE_FINISH
      requestState.state = S_ANSWER_START
      requestState.state = S_ANSWER_IN_PROGRESS
      requestState.resolve = R_GO
      requestState.state = S_ANSWER_FINISH
    ensure
      requestState.state = S_REQUEST_START
      api.bgEvents.postEvent("BannerMessage", requestState)
    end

    def onNotifyStart(requestState)
      # Put up the screen for the event
      raise "NotImplemented"
    end
  end
end