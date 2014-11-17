module Platform
  ##
  # This class merely handles event processing for the MasterMessagePresentationController
  # It is extended for the particular UI or testing environment and will be added assigned to
  # masterController.fgMasterMessagePresentationEventController.
  #
  # The masterController.bannerPresentationController.roll spawns these events.
  #
  class FG_MasterMessagePresentationEventController
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("MasterMessagePresent:display", self)
      api.uiEvents.registerForEvent("MasterMessagePresent:dismiss", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "MasterMessagePresent:display"
          displayMasterMessage(eventData.masterMessage)
        when "MasterMessagePresent:dismiss"
          dismissMasterMessage(eventData.masterMessage)
      end
    end

    def displayMasterMessage(bannerInfo)
      raise "NotImplemented"
    end

    def dismissMasterMessage(bannerInfo)
      raise "NotImplemented"
    end
  end

end