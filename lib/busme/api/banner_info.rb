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
    attr_reader   :beginSeen
    attr_accessor :onDisplayQueue

    def initialize
      @seen = false
      @onDisplayQueue = false
    end

    def lastSeen=(lastSeen)
      @lastSeen = lastSeen
    end

    def beginSeen=(time)
      @seen = true
      @beginSeen = time
    end

    def shouldBeSeen?(time)
      #!@seen || time < expiryTime && @lastSeen + frequency < time
      time < expiryTime && (!@seen || !@beginSeen && @lastSeen && @lastSeen + frequency < time)
    end

    def onDisplay(time = nil)
      time = Time.now if time.nil?
      self.beginSeen = time
    end

    def onDismiss(time = nil)
      time = Time.now if time.nil?
      self.lastSeen = time
      self.beginSeen = nil
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
      !!beginSeen && beginSeen + length < time
    end

  end
end
