module Platform
  #
  # This class handles the Foreground Thread's handling of messages
  class FGMarkerMessageController
    include Api::BuspassEventListener
    include MarkerMessageEventConstants
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("MarkerMessageEvent", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a? MarkerMessageEventData
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

    def presentMarkerMessage(eventData)
      # Display Marker Message
    end

    def dismissMarkerMessage(eventData)
      # Remove Marker Message from Display
    end

    def onPresent(eventData)
      presentMarkerMessage(eventData)
    end

    def onError(eventData)
      dismissMarkerMessage(eventData)

    end

    def onDone(eventData)
      dismissMarkerMessage(eventData)
    end

    def onOK(eventData)
      eventData.markerMessageForeground.onInquired(eventData, R_CANCEL)
      dismissMarkerMessage(eventData)
    end

    def onGo(eventData)
      eventData.markerMessageForeground.onInquired(eventData, R_GO)
      dismissMarkerMessage(eventData)
    end

    def onRemind(eventData)
      eventData.markerMessageForeground.onInquired(eventData, R_REMIND)
      dismissMarkerMessage(eventData)
    end

    def onRemove(eventData)
      eventData.markerMessageForeground.onInquired(eventData, R_REMOVE)
      dismissMarkerMessage(eventData)
    end

    def onCancel(eventData)
      eventData.markerMessageForeground.onInquired(eventData, R_CANCEL)
      dismissMarkerMessage(eventData)
    end

  end
end
