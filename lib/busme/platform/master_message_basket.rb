module Platform
  class MasterMessageBasket
    attr_accessor :api
    attr_accessor :masterMessageStore
    attr_accessor :masterMessageController

    def initialize(api, store, controller)
      self.api = api
      self.masterMessageStore = store
      self.masterMessageController = controller
    end

    def addMasterMessage(msg)
      stored_message = masterMessageStore.getMasterMessage(msg.id)
      if stored_message
        if stored_message.version < msg.version
          masterMessageStore.addMasterMessage(msg)
        end
      else
        masterMessageStore.addMasterMessage(msg)
      end
    end

    def onLocationUpdate(location, time = nil)
      time = Time.now if time.nil?
      point = location ? GeoCalc.toGeoPoint(location) : nil
      for msg in masterMessageStore.masterMessages.values do
        if msg.is_a? Api::MasterMessage
          if time <= msg.expiryTime && (!msg.seen || msg.remindTime && msg.remindTime <= time)
            if msg.point && msg.radius
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
      time = Time.now if time.nil?
      masterMessageStore.resetMessages(time)
    end

  end
end