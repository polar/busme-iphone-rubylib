module Api
  class BannerInfo
    include Encoding
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
    attr_accessor :displayed

    attr_accessor :loaded
    
    def propList
      %w(
      @id
      @point
      @version
      @length
      @frequency
      @radius
      @priority
      @expiryTime
      @title
      @description
      @goUrl
      @iconUrl
      @seen
      @lastSeen
      @beginSeen
      @onDisplayQueue
      @displayed
      @loaded
      )
    end

    def initWithCoder(decoder)
      self.id = decoder[:id]
      self.point = decoder[:point]
      self.version = decoder[:version]
      self.length = decoder[:length]
      self.frequency = decoder[:frequency]
      self.radius = decoder[:radius]
      self.priority = decoder[:priority]
      self.expiryTime = decoder[:expiryTime]
      self.title = decoder[:title]
      self.description = decoder[:description]
      self.goUrl = decoder[:goUrl]
      self.iconUrl = decoder[:iconUrl]
      self.seen = decoder[:seen]
      self.lastSeen = decoder[:lastSeen]
      self.beginSeen = decoder[:beginSeen]
      self.onDisplayQueue = decoder[:onDisplayQueue]
      self.displayed = decoder[:displayed]
      self.loaded = decoder[:loaded]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def encodeWithCoder(encoder)
      encoder[:id] = id
      encoder[:point] = point
      encoder[:version] = version
      encoder[:length] = length
      encoder[:frequency] = frequency
      encoder[:radius] = radius
      encoder[:priority] = priority
      encoder[:expiryTime] = expiryTime
      encoder[:title] = title
      encoder[:description] = description
      encoder[:goUrl] = goUrl
      encoder[:iconUrl] = iconUrl
      encoder[:seen] = seen
      encoder[:lastSeen] = lastSeen
      encoder[:beginSeen] = beginSeen
      encoder[:onDisplayQueue] = onDisplayQueue
      encoder[:displayed] = displayed
      encoder[:loaded] = loaded
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

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
      time = Utils::Time.current if time.nil?
      self.beginSeen = time
      self.displayed = true
    end

    def onDismiss(time = nil)
      time = Utils::Time.current if time.nil?
      self.lastSeen = time
      self.beginSeen = nil
      self.displayed = false
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
      self.lastSeen = Utils::Time.current
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
      self.length = tag.attributes["length"].to_f/1000.0
      self.frequency = tag.attributes["frequency"].to_f/1000.0
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

  def to_json

  end
end
