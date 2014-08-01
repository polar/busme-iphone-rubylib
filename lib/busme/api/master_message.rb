module Api
  class MasterMessage
    attr_accessor :id
    attr_accessor :title
    attr_accessor :priority
    attr_accessor :seen
    attr_accessor :content
    attr_accessor :goUrl
    attr_accessor :goLabel
    attr_accessor :remindPeriod
    attr_accessor :expiryTime

    attr_accessor :point
    attr_accessor :radius
    attr_accessor :version
    attr_accessor :displayed

    attr_accessor :loaded

    attr_accessor :remindable
    attr_accessor :remindTime

    def initialize(id = "")
      self.id = id
      self.loaded = false
      self.seen = false
      self.remindPeriod = 1000*60*60*24*7
      self.expiryTime = Time.now + 1000*60*60*24
      self.content = "No Content"
      self.title = "No Title"
    end

    def isLoaded()
      loaded
    end
    def isDisplayed
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