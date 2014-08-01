module Api
  class BannerInfo
    attr_accessor :id
    attr_accessor :point
    attr_accessor :version
    attr_accessor :length  # seconds
    attr_accessor :frequency # miliseconds
    attr_accessor :radius # feet?
    attr_accessor :priority
    attr_accessor :expiryTime
    attr_accessor :title
    attr_accessor :goUrl
    attr_accessor :iconUrl
    attr_accessor :seen
    attr_reader   :lastSeen

    def initialize
      @seen = false
      @lastSeen = 0
    end

    def lastSeen=(lastSeen)
      @seen = true
      @lastSeen = lastSeen
    end

    def shouldBeSeen(time)
      !@seen || time < expiryTime && @lastSeen + frequency < time
    end

    def nextTime(now)
      if !@seen
        now
      else
        @lastSeen + frequency
      end
    end

    def setLastSeenNow
      self.lastSeen = Time.now
    end

    def isDisplayTimeExpired(time)
      lastSeen + length < time
    end

  end
end
