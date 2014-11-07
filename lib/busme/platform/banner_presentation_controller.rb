module Platform
  ##
  # This class handles the presentation queue for displaying banners.
  # The system will call the roll method on a period basis to cycle
  # through the banners in the queue. The queue is filled by addBanner
  # handed in the background by the BannerBasket.
  class BannerPresentationController
    attr_accessor :api
    attr_accessor :currentBanner

    def initialize(api)
      self.api = api
      @bannerQ = Utils::PriorityQueue.new {|b1,b2| compare(b1,b2)}
    end

    def addBanner(banner)
      @bannerQ.push(banner)
    end

    def removeBanner(banner)
      @bannerQ.delete(banner)
    end

    def contains?(banner)
      @bannerQ.include?(banner)
    end

    def roll(removeCurrent, now = nil)
      now = Utils::Time.current  if now.nil?
      if currentBanner
        if !removeCurrent && !currentBanner.isDisplayTimeExpired?(now)
          return
        else
          abandonBanner(currentBanner)
          currentBanner.onDismiss(now)
          self.currentBanner = nil
        end
      end
      banner = @bannerQ.poll
      while banner do
        if banner.shouldBeSeen?(now)
          presentBanner(banner)
          banner.onDisplay(now)
          self.currentBanner = banner
          return
        end
        banner = @bannerQ.poll
      end
    end

    protected

    def compare(b1,b2)
      now = Utils::Time.current
      time = b1.nextTime(now) <=> b2.nextTime(now)
      if time == 0
        b1.priority <=> b2.priority
      else
        time
      end
    end

    def presentBanner(banner)
      eventData = BannerPresentEventData.new(banner)
      api.uiEvents.postEvent("BannerPresent:Display", eventData)
    end

    def abandonBanner(banner)
      eventData = BannerPresentEventData.new(banner)
      api.uiEvents.postEvent("BannerPresent:Dismiss", eventData)
    end
  end
end