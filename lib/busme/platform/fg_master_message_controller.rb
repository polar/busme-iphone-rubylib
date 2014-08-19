module Platform
  #
  # This class handles the Foreground Thread's handling of messages
  class FGMasterMessageController
    include Api::BuspassEventListener
    include MasterMessageEventConstants
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("MasterMessageEvent", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a? MasterMessageEventData
        case eventData.state
          when S_PRESENT
            onPresent(eventData)
          when S_ERROR
            onError(eventData)
          when S_DONE
            onDone(eventData)
        end
      end
    end

    def presentMasterMessage(eventData)
      # Display Master Message
    end

    def dismissMasterMessage(eventData)
      # Remove Master Message from Display
    end

    def onPresent(eventData)
      presentMasterMessage(eventData)
    end

    def onError(eventData)
      dismissMasterMessage(eventData)

    end

    def onDone(eventData)
      dismissMasterMessage(eventData)
    end

    def onOK(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_CANCEL)
      dismissMasterMessage(eventData)
    end

    def onGo(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_GO)
      dismissMasterMessage(eventData)
    end

    def onRemind(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_REMIND)
      dismissMasterMessage(eventData)
    end

    def onRemove(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_REMOVE)
      dismissMasterMessage(eventData)
    end

    def onCancel(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_CANCEL)
      dismissMasterMessage(eventData)
    end

  end
end
