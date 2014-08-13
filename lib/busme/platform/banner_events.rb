module Platform

  class BannerEventData
    attr_accessor :banner_info
    attr_accessor :thruUrl
    attr_accessor :option
    attr_accessor :state

    S_PRESENT = 0
    S_CLICK   = 1
    S_CLICKED = 2
    S_ERROR   = 3
    S_DONE    = 4

    def initialize(info)
      self.banner_info = info
      self.state       = S_PRESENT
    end
  end

  class BannerForeground
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("BannerEvent", self)
    end

    # Called from the UI Thread.
    def onBuspassEvent(event)
      case event.eventData.state
        when BannerEventData::S_PRESENT
          presentBanner(event.eventData)
        when BannerEventData::S_CLICKED
          presentBannerClickThrough(event.eventData)
        else
      end
    end

    def presentBanner(evenData)
      raise "NotImplemented"
    end

    def presentBannerClickThrough(evenData)
      raise "NotImplemented"
    end
  end

  class BannerBackground
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("BannerEvent", self)
    end

    # Called from Background Thread
    def onBuspassEvent(event)
      case event.eventData.state
        when BannerEventData::S_CLICK
          recordClickThru(event)
      end
    end

    # Called from Background Thread
    def recordClickThru(event)
      banner_info = event.eventData.banner_info
      url                     = api.getBannerClickThru(banner_info.id)
      event.eventData.thruUrl = url
      event.eventData.state   = Platform::BannerEventData::S_CLICKED
    rescue Exception => boom
      event.eventData.state = Platform::BannerEventData::S_ERROR
    ensure
      api.uiEvents.postEvent(event)
    end
  end
end