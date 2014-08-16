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
            presentMasterMessage(eventData)
          when S_ERROR
            onError(eventData)
          when S_DONE
            onDone(eventData)
        end
      end
    end

    def presentMasterMessage(eventData)

    end

    def dismissMasterMessage

    end

    def onError(eventData)

    end

    def onDone(eventData)

    end

    def onOK(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_CANCEL)
    end

    def onGo(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_GO)
    end

    def onRemind(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_REMIND)
    end

    def onRemove(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_REMOVE)
    end

    def onCancel(eventData)
      eventData.masterMessageForeground.onInquired(eventData, R_CANCEL)
    end

  end
end
