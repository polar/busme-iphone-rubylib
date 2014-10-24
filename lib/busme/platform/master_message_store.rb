module Platform
  class MasterMessageStore
    include Api::Storage
    attr_accessor :masterMessages
    attr_accessor :dirty

    def propList
      %w(@masterMessages @dirty)
    end

    def initWithCoder1(decoder)
      self.masterMessages = decoder[:masterMessages]
      self.dirty = decoder[:dirty]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def encodeWithCoder1(encoder)
      encoder[:masterMessages] = masterMessages
      encoder[:dirty] = dirty
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def initialize
      self.masterMessages = {}
      self.dirty = true
    end

    def getMasterMessages
      masterMessages.values
    end

    def addMasterMessage(msg)
      masterMessages[msg.id] = msg
      self.dirty = true
    end

    def removeMasterMessage(msg_or_id)
      masterMessages.delete(msg_or_id.id) if msg_or_id.is_a? Api::MessageSpec
      masterMessages.delete(msg_or_id)
      self.dirty = true
    end

    def resetMessages(time = nil)
      time = Time.now if time.nil?
      masterMessages.reject {|x| x.is_a?(Api::MessageSpec) && !x.is_a?(Api::MasterMessage)}
      masterMessages.each {|x| x.reset(time)}
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

    def getMasterMessage(id)
      masterMessages[id]
    end

    def preSerialize(api, time = nil)
      clean(time)
    end

    def postSerialize(api, time = nil)
      clean(time)
    end

  end
end