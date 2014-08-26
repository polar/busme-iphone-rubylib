module Platform
  class BG_BannerMessageEventController < RequestController
    include BannerMessageConstants
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("MasterMessage", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "MasterMessage"
          onRequestState(eventData)
      end
    end

    def onStart(requestState)
      requestState.state = S_INQUIRE_START
      api.uiEvents.postEvent("MasterMessage", requestState)
    end

    def onRequestStart(eventData)
      eventData.state = S_REQUEST_IN_PROGRESS
      masterMessage = eventData.masterMessage
      case eventData.resolve
        when R_GO
          begin
            url = api.getMasterMessageClickThru(masterMessage.id)
            eventData.state = S_RESPONSE_FINISH
            eventData.thruUrl = url || masterMessage.goUrl
          rescue Exception => boom
            eventData.thruUrl = masterMessage.goUrl
            eventData.state = S_RESPONSE_ERROR
          end
        when R_REMIND
          # We really do not have a remind or remove for banners. Same as cancel
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
      api.uiEvents.postEvent("MasterMessage", eventData)
    end
  end
end