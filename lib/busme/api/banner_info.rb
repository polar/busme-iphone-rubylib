module Api
  class BannerInfo
    attr_accessor :id
    attr_accessor :point
    attr_accessor :version
    attr_accessor :length  # seconds
    attr_accessor :frequency # seconds
    attr_accessor :radius # feet?
    attr_accessor :priority
    attr_accessor :expiryTime
    attr_accessor :title
    attr_accessor :goUrl
    attr_accessor :iconUrl
    attr_accessor :seen
    attr_reader   :lastSeen
    attr_accessor :onDisplayQueue

    def initialize
      @seen = false
      @lastSeen = 0
      @onDisplayQueue = false
    end

    def lastSeen=(lastSeen)
      @seen = true
      @lastSeen = lastSeen
    end

    def shouldBeSeen?(time)
      #!@seen || time < expiryTime && @lastSeen + frequency < time
      time < expiryTime && (!@seen || @lastSeen + length + frequency < time)
    end

    ##
    # Only a valid call if shouldBeSeen! is true
    #
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

    def isDisplayTimeExpired?(time)
      lastSeen + length < time
    end

  end
end
