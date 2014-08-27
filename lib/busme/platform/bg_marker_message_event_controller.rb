module Platform
  class BG_MarkerMessageEventController < RequestController
    include MarkerMessageConstants
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("MarkerMessage", self)
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
      api.uiEvents.postEvent("MarkerMessage", requestState)
    end

    def onRequestStart(eventData)
      eventData.state = S_REQUEST_IN_PROGRESS
      marker_info = eventData.marker_info
      case eventData.resolve
        when R_GO
          begin
            url = api.getMarkerClickThru(marker_info.id)
            eventData.state = S_RESPONSE_FINISH
            eventData.thruUrl = url || marker_info.goUrl
          rescue Exception => boom
            eventData.thruUrl = marker_info.goUrl
            eventData.state = S_RESPONSE_ERROR
            eventData.error = boom
          end
        when R_REMIND
          # We really do not have a remind or remove for markers. Same as cancel
          eventData.state = S_RESPONSE_FINISH
        when R_REMOVE
          eventData.state = S_RESPONSE_FINISH
        when R_CANCEL
          eventData.state = S_RESPONSE_FINISH
      end
    rescue Exception => boom
      eventData.state = S_REQUEST_ERROR
      eventData.error = boom
    ensure
      eventData.state = S_NOTIFY_START
      api.uiEvents.postEvent("MarkerMessage", eventData)
    end
  end
end