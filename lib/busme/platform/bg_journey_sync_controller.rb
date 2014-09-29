module Platform

  class JourneySyncEventData
    attr_accessor :isForced
  end

  class BG_JourneySyncController
    include Api::BuspassEventListener
    attr_accessor :api
    attr_accessor :journeyDisplayController
    attr_accessor :syncProgressListener

    def initialize(api, journeyDisplayController)
      self.api = api
      self.journeyDisplayController = journeyDisplayController
      self.syncProgressListener = JourneySyncProgressEventListener.new(api)
      api.bgEvents.registerForEvent("JourneySync", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      onSync(eventData)
    end

    def onSync(eventData)
      invocation = JourneySyncRemoteInvocation.new(api, journeyDisplayController, syncProgressListener)
      invocation.perform(eventData.isForced)
    end

  end
end