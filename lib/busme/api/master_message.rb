module Api
  class MasterMessage  < MessageSpec
    attr_accessor :title
    attr_accessor :priority
    attr_accessor :seen
    attr_accessor :content
    attr_accessor :goUrl
    attr_accessor :goLabel
    attr_accessor :remindPeriod

    attr_accessor :point
    attr_accessor :radius
    attr_accessor :displayed

    attr_accessor :loaded

    attr_accessor :lastSeen
    attr_accessor :remindable
    attr_accessor :remindTime
    
    def propList
      (super.propList) +
      %w(
    @title
    @priority
    @seen
    @content
    @goUrl
    @goLabel
    @remindPeriod

    @point
    @radius
    @displayed

    @loaded

    @lastSeen
    @remindable
    @remindTime
      )
    end

    def initWithCoder1(decoder)
      super(decoder)
      self.title = decoder[:title]
      self.priority = decoder[:priority]
      self.seen = decoder[:seen]
      self.content = decoder[:content]
      self.goUrl = decoder[:goUrl]
      self.goLabel = decoder[:goLabel]
      self.remindPeriod = decoder[:remindPeriod]
      self.point = decoder[:point]
      self.radius = decoder[:radius]
      self.displayed = decoder[:displayed]
      self.loaded = decoder[:loaded]
      self.lastSeen = decoder[:lastSeen]
      self.remindable = decoder[:remindable]
      self.remindTime = decoder[:remindTime]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def encodeWithCoder1(encoder)
      super(encoder)
      encoder[:title] = title
      encoder[:priority] = priority
      encoder[:seen] = seen
      encoder[:content] = content
      encoder[:goUrl] = goUrl
      encoder[:goLabel] = goLabel
      encoder[:remindPeriod] = remindPeriod
      encoder[:point] = point
      encoder[:radius] = radius
      encoder[:displayed] = displayed
      encoder[:loaded] = loaded
      encoder[:lastSeen] = lastSeen
      encoder[:remindable] = remindable
      encoder[:remindTime] = remindTime
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def initialize(id = "")
      super(id, nil, nil)
      self.id = id
      self.loaded = false
      self.seen = false
      self.remindPeriod = 1000*60*60*24*7
      self.expiryTime = Utils::Time.current + 1000*60*60*24
      self.content = "No Content"
      self.title = "No Title"
    end

    def isLoaded()
      loaded
    end
    def isDisplayed?
      displayed
    end
    def isSeen()
      seen
    end

    def setRemindTime(time, forward)
      self.remindTime = time + forward
    end

    def resetRemindTime(time)
      setRemindTime(time, remindPeriod)
    end

    def shouldBeSeen?(time)
      time < expiryTime && (!seen || (remindable && (remindTime ? remindTime < time : false)))
    end

    # This is used for sorting. Basically if it is not seen or expired the time is
    # is basically now, so that it will come up at the beginning of the list and be
    # disposed of by the controller. If it has a later remindTime that will be sorted
    # appropriately.
    def nextTime(time = nil)
      time = Utils::Time.current if time.nil?
      if time < expiryTime
        if !seen
          time
        else
          if remindable && remindTime
            remindTime
          else
            time
          end
        end
      else
        time
      end
    end

    def reset(time = nil)
      time = Utils::Time.current if time.nil?
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
      point = Integration::GeoPoint.new(lat * 1E6, lon * 1E6)
      self.radius = tag.attributes["radius"].to_i
      self.loaded = true
    end
  end
end