module Platform
  class MasterMessageStore
    attr_accessor :masterMessages
    attr_accessor :seenMessages
    attr_accessor :dirty

    def initialize
      self.masterMessages = {}
      self.dirty = true
    end

    def addMasterMessage(msg)
      masterMessages[msg.id] = msg
      self.dirty = true
    end

    def removeMasterMessage(msg_or_id)
      masterMessages.delete(msg_or_id.id) if msg.is_a? Api::MessageSpec
      masterMessages.delete(msg_or_id)
      self.dirty = true
    end

    def resetMessages
      masterMessages.reject {|x| x.is_a?(Api::MessageSpec) && !x.is_a?(Api::MasterMessage)}
      masterMessages.each {|x| x.reset}
      self.dirty = true
    end

    def clean(time = nil)
      time = Time.now if time.nil?
      masterMessages.values.each do |msg|
        if msg.expiryTime < time
          masterMessages.delete(msg.id)
        elsif msg.seen && (!msg.remindable || msg.remindTime.nil?)
          masterMessages[msg.id] = Api::MessageSpec.new(msg.id, msg.version, msg.expiryTime)
        end
        self.dirty = true
      end
    end

    def preSerialize(time = nil)
      clean(time)
    end

    def postSerialize(time = nil)
      clean(time)
    end

  end
end