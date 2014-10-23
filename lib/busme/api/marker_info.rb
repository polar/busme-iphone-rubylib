module Api
  class MarkerInfo < MessageSpec
    attr_accessor :point
    attr_accessor :radius # feet
    attr_accessor :title
    attr_accessor :description
    attr_accessor :goUrl
    attr_accessor :goLabel
    attr_accessor :content
    attr_accessor :iconUrl
    attr_accessor :loaded
    attr_accessor :priority

    attr_accessor :seen
    attr_accessor :lastSeen
    attr_accessor :displayed
    attr_accessor :remindable
    attr_accessor :remindPeriod
    attr_accessor :remindTime
    
    def propList
      super.propList +
      %w(
    @point
    @radius
    @title
    @description
    @goUrl
    @goLabel
    @content
    @iconUrl
    @loaded
    @priority

    @seen
    @lastSeen
    @displayed
    @remindable
    @remindPeriod
    @remindTime
      )
    end

    def initWithCoder1(decoder)
      super(decoder)
      self.point = decoder[:point]
      self.radius = decoder[:radius]
      self.title = decoder[:title]
      self.description = decoder[:description]
      self.goUrl = decoder[:goUrl]
      self.goLabel = decoder[:goLabel]
      self.content = decoder[:content]
      self.iconUrl = decoder[:iconUrl]
      self.loaded = decoder[:loaded]
      self.priority = decoder[:priority]
      self.seen = decoder[:seen]
      self.lastSeen = decoder[:lastSeen]
      self.displayed = decoder[:displayed]
      self.remindable = decoder[:remindable]
      self.remindPeriod = decoder[:remindPeriod]
      self.remindTime = decoder[:remindTime]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def encodeWithCoder1(encoder)
      super(encoder)
      encoder[:point] = point
      encoder[:radius] = radius
      encoder[:title] = title
      encoder[:description] = description
      encoder[:goUrl] = goUrl
      encoder[:goLabel] = goLabel
      encoder[:content] = content
      encoder[:iconUrl] = iconUrl
      encoder[:loaded] = loaded
      encoder[:priority] = priority
      encoder[:seen] = seen
      encoder[:lastSeen] = lastSeen
      encoder[:displayed] = displayed
      encoder[:remindable] = remindable
      encoder[:remindPeriod] = remindPeriod
      encoder[:remindTime] = remindTime
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def initialize
      super(nil,nil,nil)
    end


    def shouldBeSeen?(time)
      time < expiryTime && (!seen || (remindable && (remindTime ? remindTime < time : false)))
    end

    # This is used for sorting. Basically if it is not seen or expired the time is
    # is basically high, so that it will come up at the end of the list and be
    # disposed of by the controller. If it has a later remindTime that will be sorted
    # appropriately.
    def nextTime(time = nil)
      time = Time.now if time.nil?
      if time < expiryTime
        if remindable && remindTime
          remindTime
        else
          time + 10 * 365 * 24 * 60 * 60
        end
      else
        time + 10 * 365 * 24 * 60 * 60
      end
    end

    def reset(time = nil)
      time = Time.now if time.nil?
      self.seen = false
      self.lastSeen = nil
      self.displayed = false
      self.remindTime = nil
    end

    def onDisplay(time)
      self.seen = true
      self.lastSeen = time
      self.displayed = true
    end

    def onDismiss(remind, time)
      self.displayed = false
      self.lastSeen = time
      if remind && remindable && remindPeriod
        self.remindTime = time + remindPeriod
      end
    end

    def loadParsedXML(tag)
      self.id = tag.attributes["id"]
      self.goUrl = tag.attributes["goUrl"]
      self.iconUrl = tag.attributes["iconUrl"]
      self.remindable = "true" == tag.attributes["remindable"]
      for m in tag.childNodes
        case m.name
          when "Title"
            self.title = m.text
          when "Content"
            self.content = m.text
          when "GoLabel"
            self.goLabel = m.text
        end
      end
      self.expiryTime = Time.at(tag.attributes["expiryTime"].to_i)
      self.priority = tag.attributes["priority"].to_f
      self.remindPeriod = tag.attributes["remindPeriod"].to_i
      self.version = tag.attributes["version"].to_i
      lon = tag.attributes["lon"].to_f
      lat = tag.attributes["lat"].to_f
      self.point = Integration::GeoPoint.new(lat * 1E6, lon * 1E6)
      self.radius = tag.attributes["radius"].to_i
      self.loaded = true
    end
  end

end