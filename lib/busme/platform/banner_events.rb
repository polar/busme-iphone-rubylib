module Platform
  
  module BannerEventConstants
    S_PRESENT  = 0
    S_INQUIRED = 1
    S_RESOLVED = 2
    S_ERROR    = 3
    S_DONE     = 4

    R_GO     = 1
    R_REMIND = 2
    R_REMOVE = 3
    R_CANCEL = 4
  end
  

  class BannerEventData
    include BannerEventConstants
    attr_accessor :banner_info
    attr_accessor :thruUrl
    attr_accessor :resolve
    attr_accessor :resolveData
    attr_accessor :state
    attr_accessor :bannerForeground
    attr_accessor :bannerBackground

    def initialize(info)
      self.banner_info = info
      self.state       = S_PRESENT
    end

    def dup
      evd = BannerEventData.new(banner_info)
      evd.thruUrl = thruUrl
      evd.resolve = resolve
      evd.resolveData = resolveData
      evd.state = state
      evd.bannerForeground = bannerForeground
      evd.bannerBackground = bannerBackground
      evd
    end
  end

  class BannerForeground
    include BannerEventConstants
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("BannerEvent", self)
    end

    # Called from the UI Thread.
    def onBuspassEvent(event)
      event.eventData.bannerForeground = self
      case event.eventData.state
        when S_PRESENT
          onPresent(event.eventData)
        when S_RESOLVED
          onResolved(event.eventData)
        when S_ERROR
          onError(event.eventData)
        when S_DONE
          onDone(event.eventData)
        else
      end
    end

    # Called from UI Thread
    # Should Overridden to display message
    def onPresent(eventData)
      eventData.banner_info.onDisplay(Utils::Time.current)
    end

    # Called on Foreground Thread by way of UI invoking
    #      eventData.bannerForeground.onInquired(eventData, resolution)
    # Should be called to resolve message with a resolution
    # Override to maybe get rid of message from display, or wait until onResolved
    def onInquired(eventData, resolve)
      eventData = eventData.dup
      eventData.resolve = resolve
      eventData.state = S_INQUIRED
      api.bgEvents.postEvent("BannerEvent", eventData)
    end

    # Should Overridden to handle dismissal of message if needed.
    def onResolved(eventData)
      case eventData.resolve
        when R_GO
        when R_REMIND
        when R_REMOVE
        when R_CANCEL
      end
      eventData = eventData.dup
      eventData.state = S_DONE
      api.bgEvents.postEvent("BannerEvent", eventData)
    end

    # Should Overridden
    def onError(eventData)
      eventData = eventData.dup
      eventData.state = S_DONE
      api.bgEvents.postEvent("BannerEvent", eventData)
    end

    # Should Overridden
    def onDone(eventData)
      eventData.banner_info.onDismiss(Utils::Time.current)
    end
  end

  class BannerBackground
    include BannerEventConstants
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("BannerEvent", self)
    end

    # Called from Background Thread
    def onBuspassEvent(event)
      event.eventData.bannerBackground = self

      case event.eventData.state
        when S_INQUIRED
          onInquired(event.eventData)
        when S_ERROR
          onError(event.eventData)
        when S_DONE
          onDone(event.eventData)
      end
    end


    # Called from Background Thread
    def onInquired(eventData)
      eventData = eventData.dup
      banner_info = eventData.banner_info
      case eventData.resolve
        when R_GO
          begin
            url = api.getBannerClickThru(banner_info.id)
            eventData.thruUrl = url || banner_info.goUrl
          rescue Exception => boom
            eventData.thruUrl = banner_info.goUrl
          end
        when R_REMIND
          # We really do not have a remind or remove for banners. Same as cancel
        when R_REMOVE
        when R_CANCEL
      end
      eventData.state = S_RESOLVED
    rescue Exception => boom
      eventData.state = S_ERROR
    ensure
      api.uiEvents.postEvent("BannerEvent", eventData)
    end

    # May be Overridden
    def onError(eventData)
      eventData = eventData.dup
      api.uiEvents.postEvent("BannerEvent", eventData)
    end

    # May be  Overridden
    def onDone(eventData)
      eventData = eventData.dup
      api.uiEvents.postEvent("BannerEvent", eventData)
    end
  end
end
