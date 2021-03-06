module Platform
  class MarkerStore
    include Api::Storage
    attr_accessor :markers
    attr_accessor :dirty

    def propList
      %w(@markers @dirty)
    end

    def initWithCoder1(decoder)
      self.markers = decoder[:markers]
      self.dirty = decoder[:dirty]
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def encodeWithCoder1(encoder)
      encoder[:markers] = markers
      encoder[:dirty] = dirty
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def initialize
      self.markers = {}
      self.dirty = true
    end

    def getMarkers
      markers.values
    end

    def getMarker(id)
      markers[id]
    end

    def addMarker(msg)
      markers[msg.id] = msg
      self.dirty = true
    end

    def removeMarker(msg_or_id)
      markers.delete(msg_or_id.id) if msg_or_id.is_a? Api::MarkerInfo
      markers.delete(msg_or_id)
      self.dirty = true
    end

    def resetMarkers(time = nil)
      time = Utils::Time.current if time.nil?
      markers.reject {|x| x.is_a?(Api::MessageSpec) && !x.is_a?(Api::MarkerInfo)}
      markers.each {|x| x.reset(time)}
      self.dirty = true
    end

    def clean(time = nil)
      time = Utils::Time.current if time.nil?
      markers.values.each do |msg|
        if msg.expiryTime && msg.expiryTime < time
          markers.delete(msg.id)
        elsif msg.is_a?(Api::MarkerInfo) && msg.seen && (!msg.remindable || msg.remindTime.nil?)
          markers[msg.id] = Api::MessageSpec.new(msg.id, msg.version, msg.expiryTime)
        end
        self.dirty = true
      end
    end

    def getMasterMessage(id)
      markers[id]
    end

    def preSerialize(api, time = nil)
      clean(time)
    end

    def postSerialize(api, time = nil)
      clean(time)
    end

  end
end