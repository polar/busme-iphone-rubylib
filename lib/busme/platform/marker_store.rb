module Platform
  class MarkerStore
    attr_accessor :markers
    attr_accessor :dirty

    def initialize
      self.markers = {}
      self.dirty = true
    end

    def addMarker(msg)
      markers[msg.id] = msg
      self.dirty = true
    end

    def removeMaker(msg_or_id)
      markers.delete(msg_or_id.id) if msg.is_a? Api::MarkerInfo
      markers.delete(msg_or_id)
      self.dirty = true
    end

    def resetMarkers(time = nil)
      time = Time.now if time.nil?
      markers.reject {|x| x.is_a?(Api::MessageSpec) && !x.is_a?(Api::MarkerInfo)}
      markers.each {|x| x.reset(time)}
      self.dirty = true
    end

    def clean(time = nil)
      time = Time.now if time.nil?
      markers.values.each do |msg|
        if msg.expiryTime < time
          markers.delete(msg.id)
        elsif msg.seen && (!msg.remindable || msg.remindTime.nil?)
          markers[msg.id] = Api::MessageSpec.new(msg.id, msg.version, msg.expiryTime)
        end
        self.dirty = true
      end
    end

    def getMasterMessage(id)
      markers[id]
    end

    def preSerialize(time = nil)
      clean(time)
    end

    def postSerialize(time = nil)
      clean(time)
    end

  end
end