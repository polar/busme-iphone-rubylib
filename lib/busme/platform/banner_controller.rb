module Platform
  class BannerController
    attr_accessor :currentBanner

    def initialize
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
      now = Time.now  if now.nil?
      remove = false
      if currentBanner
        if !removeCurrent && !currentBanner.isDisplayTimeExpired?(now)
          return
        else
          remove = true
        end
      end
      banner = @bannerQ.poll
      while banner do
        if banner.shouldBeSeen?(now)
          presentBanner(banner)
          banner.lastSeen = now
          self.currentBanner = banner
          return
        end
        banner = @bannerQ.poll
      end
      if remove
        abandonBanner(currentBanner)
        self.currentBanner = nil
      end
    end

    protected

    def compare(b1,b2)
      now = Time.now
      time = b1.nextTime(now) <=> b2.nextTime(now)
      if time == 0
        b1.priority <=> b2.priority
      else
        time
      end
    end

    def presentBanner(currentBanner)
      raise "NotImplemented"
    end

    def abandonBanner(currentBanner)
      raise "NotImplemented"
    end
  end
end