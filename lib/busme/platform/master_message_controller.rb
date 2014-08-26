module Platform
  class MasterMessageController
    attr_accessor :api
    attr_accessor :currentMasterMessage

    def initialize(api)
      self.api = api
      @messageQ = Utils::PriorityQueue.new {|lhs,rhs| compare(lhs,rhs)}
    end

    def addMasterMessage(msg)
      @messageQ.push(msg)
    end

    def removeMasterMessage(msg)
      @messageQ.delete(msg)
    end

    def contains?(msg)
      @messageQ.include?(msg)
    end

    def roll(now = nil)
      now = Time.now  if now.nil?
      if currentMasterMessage && currentMasterMessage.isDisplayed?
        # message must be dismissed first
        return
      end
      # We sort because we have present time calculations.
      @messageQ.sort!
      msg = @messageQ.poll
      while msg do
        if msg.shouldBeSeen?(now)
          presentMasterMessage(msg)
          msg.onDisplay(now)
          self.currentMasterMessage = msg
          return
        end
        msg = @messageQ.poll
      end
    end

    def dismissCurrentMasterMessage(remind, time = nil)
      time = Time.now if time.nil?
      if currentMasterMessage
        currentMasterMessage.onDismiss(remind, time)
      end
      self.currentMasterMessage = nil
    end

    protected

    def compare(b1,b2)
      now = Time.now
      time = b1.nextTime(now) <=> b2.nextTime(now)
      if time == 0
        b1.priority <=> b2.priority
      else
        time
      end
    end

    def presentMasterMessage(msg)
      eventData = MasterMessageEventData.new(msg)
      api.uiEvents.postEvent("MasterMessage", eventData)
    end
  end
end