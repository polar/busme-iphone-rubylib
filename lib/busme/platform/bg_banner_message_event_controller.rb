module Platform
  class BG_BannerMessageEventController < RequestController
    include BannerMessageConstants
    include Api::BuspassEventListener
    attr_accessor :api
    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("BannerMessage", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "BannerMessage"
          onRequestState(eventData)
      end
    end

    def onRequestStart(eventData)
      eventData.state = S_REQUEST_IN_PROGRESS
      banner_info = eventData.banner_info
      case eventData.resolve
        when R_GO
          begin
            url = api.getBannerClickThru(banner_info.id)
            eventData.state = S_RESPONSE_FINISH
            eventData.thruUrl = url || banner_info.goUrl
          rescue Exception => boom
            eventData.thruUrl = banner_info.goUrl
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
      api.uiEvents.postEvent("BannerMessage", eventData)
    end
  end
end