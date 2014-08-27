module Platform

  class BG_UpdateRemoteInvocationEventController
    include Api::BuspassEventListener
    attr_accessor :api
    attr_accessor :enabled
    attr_accessor :updateRemoteInvocation

    def initialize(api, updateRemoteInvocation)
      self.api = api
      self.updateRemoteInvocation = updateRemoteInvocation
      api.bgEvents.registerForEvent("Update", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.pleaseStop
        self.enabled = false
        return
      end
      if enabled
        updateRemoteInvocation.invoke(eventData.progressListener, eventData.isForced)
      end
    end
  end
end