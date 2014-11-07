module Platform
  ##
  # This class handles the base implementation to be extended by the
  # actual UI for onNotifyStart, which is supposed to take the
  # go URL and bring up a browser, or browser window containing
  # the page for the thruURL.
  #
  class FG_MasterMessageEventController < RequestController
    include MasterMessageConstants
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("MasterMessage", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "MasterMessage"
          onRequestState(eventData)
      end
    end

    def onInquireStart(requestState)
      # Normally put up dialog.
      requestState.state = S_INQUIRE_IN_PROGRESS
      # assign buttons to configure call
      requestState.state = S_INQUIRE_FINISH
    ensure
      requestState.state = S_ANSWER_START
    end

    def resolveGo(requestState)
      requestState.resolve = R_GO
      requestState.masterMessage.onDismiss(false, Utils::Time.current)
      requestState.state = S_ANSWER_FINISH
    ensure
      requestState.state = S_REQUEST_START
      api.bgEvents.postEvent("MasterMessage", requestState)
    end

    def resolveRemind(requestState)
      requestState.resolve = R_REMIND
      requestState.masterMessage.onDismiss(true, Utils::Time.current)
      requestState.state = S_ANSWER_FINISH
      requestState.state = S_REQUEST_START
      api.bgEvents.postEvent("MasterMessage", requestState)
    end

    def resolveCancel(requestState)
      requestState.resolve = R_GO
      requestState.masterMessage.onDismiss(false, Utils::Time.current)
      requestState.state = S_ANSWER_FINISH
    end

    def resolveOK(requestState)
      requestState.resolve = R_OK
      requestState.masterMessage.onDismiss(false, Utils::Time.current)
      requestState.state = S_ANSWER_FINISH
    end

    def onNotifyStart(requestState)
      # Put up the browser for the thruURL
      requestState.state = S_NOTIFY_IN_PROGRESS
      requestState.state = S_NOTIFY_FINISH
      requestState.state = S_ACK_START
    end

    def ackOK(requestState)
      requestState.state = S_ACK_IN_PROGRESS
      requestState.state = S_ACK_FINISH
      requestState.state = S_FINISH
    end
  end
end