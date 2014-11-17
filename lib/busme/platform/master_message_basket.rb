module Platform
  class MasterMessageBasket
    attr_accessor :masterMessageStore
    attr_accessor :masterMessageController

    def initialize(store, controller)
      self.masterMessageStore = store
      self.masterMessageController = controller
    end

    def getMasterMessages
      masterMessageStore.getMasterMessages
    end

    def removeMasterMessage(id)
      masterMessageStore.removeMasterMessage(id)
    end

    def addMasterMessage(msg)
      puts "MasterMessageBasket addMasterMessage #{msg.inspect}"
      stored_message = masterMessageStore.getMasterMessage(msg.id)
      if stored_message
        if stored_message.version < msg.version
          masterMessageController.removeMasterMessage(stored_message)
          masterMessageStore.addMasterMessage(msg)
        end
      else
        masterMessageStore.addMasterMessage(msg)
      end
    end

    def onLocationUpdate(location, time = nil)
      puts "MasterMessageBasket onLocationUpdate #{location.inspect}"
      time = Utils::Time.current if time.nil?
      point = location ? GeoCalc.toGeoPoint(location) : nil
      for msg in masterMessageStore.masterMessages.values do
        if msg.is_a? Api::MasterMessage
          if (!msg.expiryTime || time <= msg.expiryTime) && (!msg.seen || msg.remindTime && msg.remindTime <= time)
            if msg.point && msg.radius && msg.radius > 0
              dist = GeoCalc.getGeoDistance(point, msg.point)
              if dist < msg.radius
                masterMessageController.addMasterMessage(msg)
              end
            else
              masterMessageController.addMasterMessage(msg)
            end
          end
        end
      end
    end

    def resetMessages(time = nil)
      time = Utils::Time.current if time.nil?
      masterMessageStore.resetMessages(time)
    end

  end
end