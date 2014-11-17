module Platform
  # This controller handles messages given to it by the MasterMessageBasket
  # for display. It handles a queue and only displays one at a time.
  class MasterMessageController
    attr_accessor :api
    attr_accessor :currentMasterMessage

    def initialize(api)
      self.api = api
      @messageQ = Utils::PriorityQueue.new {|lhs,rhs| compare(lhs,rhs)}
    end

    def addMasterMessage(msg)
      puts "MasterMessageController.addMasterMessage #{msg.inspect}"
      @messageQ.push(msg)
    end

    def removeMasterMessage(msg)
      puts "MasterMessageController.removeMasterMessage #{msg.inspect}"
      @messageQ.delete(msg)
      if currentMasterMessage && (currentMasterMessage == msg || curentMasterMessage.id == msg.id)
        dismissCurrentMasterMessage(false)
      end
    end

    def contains?(msg)
      @messageQ.include?(msg)
    end

    def roll(now = nil)
      puts "MasterMessageController.roll #{currentMasterMessage}"
      now = Utils::Time.current  if now.nil?
      if currentMasterMessage && currentMasterMessage.isDisplayed?
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

    def onDismiss
      self.currentMasterMessage = nil
    end

    def dismissCurrentMasterMessage(remind, time = nil)
      time = Utils::Time.current if time.nil?
      if currentMasterMessage
        currentMasterMessage.onDismiss(remind, time)
        abandonMasterMessage(currentMasterMessage)
      end
      self.currentMasterMessage = nil
    end

    protected

    def compare(b1,b2)
      now = Utils::Time.current
      time = b1.nextTime(now) <=> b2.nextTime(now)
      if time == 0
        b1.priority <=> b2.priority
      else
        time
      end
    end

    def presentMasterMessage(msg)
      puts "MasterMessageController.presentMasterMessage #{msg.inspect}"
      eventData = MasterMessageEventData.new(msg)
      api.uiEvents.postEvent("MasterMessagePresent:display", eventData)
    end

    def abandonMasterMessage(msg)
      puts "MasterMessageController.abandonMasterMessage #{msg.inspect}"
      eventData = MasterMessageEventData.new(msg)
      api.uiEvents.postEvent("MasterMessagePresent:dismiss", eventData)
    end

  end
end