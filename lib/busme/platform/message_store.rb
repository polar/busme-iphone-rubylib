module Platform
  class MessageStore

    class SeenMessage
      attr_accessor :id
      attr_accessor :version
      def initialize(id, version)
        self.id = id
        self.version = version
      end
    end

    attr_accessor :seenMessages
    attr_accessor :messages
    attr_accessor :dirty

    def initialize
      self.seenMessages = {}
      self.messages = {}
    end

    def isNowSeen(msg)
      m1 = messages[msg.id]
      if m1
        m1.seen = true
        messages.delete msg.id
      end
      msg.seen = true
      seenMessages[msg.id] = SeenMessage.new(msg.id, msg.version)
      self.dirty = true
    end

    def clean(time)
      for msg in messages.values do
        if time > msg.expiryTime
          seenMessages.delete msg.id
          messages.delete msg
          self.dirty = true
        end
      end
    end

    def getSeenMessages
      seenMessages.dup
    end

    def reset
      seenMessages = {}
      self.dirty = true
    end

    def storeRemindedMessage(msg)
      msg.resetRemindTime(Time.now)
      msg.seen = false
      seenMessages.delete msg.id
      messages[msg.id] = msg
      self.dirty = true
    end

    def retrieveRemindedMessage(id, time)
      msg = messages[id]
      if msg
        if !msg.seen && time <= msg.expiryTime
          if time >= msg.remindTime
            return msg
          end
        end
      end
      return nil
    end

    def retrieveRemindedMessages(time)
      msgs = []
      for msg in messages.values do
        if !msg.seen && time <= msg.expiryTime
          if time > msg.remindTime
            msgs << msg
          end
        end
      end
      msgs
    end

    def removeMessage(id)
      msg = messages[id]
      if msg
        messages.delete msg
        self.dirty = true
      end
      msg != nil
    end

    def isSeen(id)
      seenMessages.keys.include?(id)
    end
    def neverSeen(id)
      !seenMessages.keys.include?(id) && !messages.keys.include?(id)
    end

    def shouldBeShown(id, time)
      neverSeen(id) || nil != retrieveRemindedMessage(id, time)
    end

    def shouldBeShownMsg(msg, time)
      if msg.expiryTime >= time
        neverSeen(msg.id) ||
            isSeen(msg.id) && seenMessages[id].version < msg.version ||
            messages.keys.include(msg.id) && messages[msg.id].version < msg.version ||
            nil != retrieveRemindedMessage(msg.id, time)
      else
        false
      end
    end

    def preSerialize
      clean(Time.now)
    end

    def postSerialize()
      clean(Time.now)
    end
  end
end