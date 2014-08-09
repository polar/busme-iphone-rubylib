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
    attr_accessor :description
    attr_accessor :goUrl
    attr_accessor :iconUrl
    attr_accessor :seen
    attr_reader   :lastSeen
    attr_reader   :beginSeen
    attr_accessor :onDisplayQueue

    attr_accessor :loaded

    def initialize
      @seen = false
      @loaded = false
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

    def loadParsedXML(tag)
      self.id = tag.attributes["id"]
      self.goUrl = tag.attributes["goUrl"]
      self.iconUrl = tag.attributes["iconUrl"]
      for m in tag.childNodes
        case m.name
          when "Title"
            self.title = m.text
          when "Description"
            self.description = m.text
        end
      end
      self.length = tag.attributes["length"].to_f
      self.frequency = tag.attributes["frequency"].to_f
      self.expiryTime = Time.at(tag.attributes["expiryTime"].to_i)
      self.priority = tag.attributes["priority"].to_f
      self.version = tag.attributes["version"].to_i
      lon = tag.attributes["lon"].to_f
      lat = tag.attributes["lat"].to_f
      self.point = Integration::GeoPoint.new(lat * 1E6, lon * 1E6)
      self.radius = tag.attributes["radius"].to_i
      self.loaded = true
    end

  end
end
