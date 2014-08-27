module Platform
  ##
  # This class handles the base implementation to be extended by the
  # actual UI for onNotifyStart, which is supposed to take the
  # go URL and bring up a browser, or browser window containing
  # the page for the thruURL.
  #
  class FG_MarkerMessageEventController < RequestController
    include MarkerMessageConstants
    attr_accessor :api
    attr_accessor :markerPresentationController

    def initialize(api, markerPresentationController)
      self.api = api
      self.markerPresentationController = markerPresentationController
      api.uiEvents.registerForEvent("MarkerMessage", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "MarkerMessage"
          onRequestState(eventData)
      end
    end

    def onStart(requestState)
      requestState.state = S_INQUIRE_START
      onInquireStart(requestState)
    end

    def onInquireStart(requestState)
      # Put up dialog showing the message for the marker
      requestState.state = S_INQUIRE_IN_PROGRESS
      requestState.state = S_INQUIRE_FINISH
      requestState.state = S_ANSWER_START
    end

    def resolveGo(requestState)
      requestState.state = S_ANSWER_IN_PROGRESS
      requestState.resolve = R_GO
      requestState.state = S_ANSWER_FINISH
    ensure
      requestState.state = S_REQUEST_START
      api.bgEvents.postEvent("MarkerMessage", requestState)
    end

    def resolveOK(requestState)
      requestState.state = S_ANSWER_IN_PROGRESS
      requestState.resolve = R_OK
      requestState.state = S_ANSWER_FINISH
    ensure
      dismissMarkerMessage(requestState)
      requestState.state = S_FINISH
    end

    def resolveRemind(requestState)
      requestState.state = S_ANSWER_IN_PROGRESS
      requestState.resolve = R_REMIND
      requestState.state = S_ANSWER_FINISH
      markerPresentationController.removeDisplayedMarker(requestState.marker_info)
    ensure
      dismissMarkerMessage(requestState)
      requestState.state = S_FINISH
    end

    def resolveRemove(requestState)
      requestState.state = S_ANSWER_IN_PROGRESS
      requestState.resolve = R_REMOVE
      requestState.state = S_ANSWER_FINISH
      markerPresentationController.removeDisplayedMarker(requestState.marker_info)
    ensure
      dismissMarkerMessage(requestState)
      requestState.state = S_FINISH
    end

    def resolveCancel(requestState)
      requestState.state = S_ANSWER_IN_PROGRESS
      requestState.resolve = R_CANCEL
      requestState.state = S_ANSWER_FINISH
    ensure
      dismissMarkerMessage(requestState)
      requestState.state = S_FINISH
    end

    def onNotifyStart(requestState)
      # Put up the browser for the thruUrl
      requestState.state = S_NOTIFY_IN_PROGRESS
      requestState.state = S_NOTIFY_FINISH
    ensure
      requestState.state = S_ACK_START
    end

    def ackOK(requestState)
      requestState.state = S_ACK_IN_PROGRESS
      requestState.state = S_ACK_FINISH
      dismissMarkerMessage(requestState)
      requestState.state = S_FINISH
    end

    def dismissMarkerMessage(eventData)
      # Should get rid of the current displayed message.
    end

  end
end