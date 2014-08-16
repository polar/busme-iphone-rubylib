module Platform
  class NetworkEventData
    attr_accessor :reason
    attr_accessor :login
  end

  class FGNetworkProblemController
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("NetworkProblem", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a? NetworkEventData
        present(eventData)
      end

    end

    def present(eventData)

    end

    def dismiss(eventData)

    end

    def onOK(eventData)

    end

    def onCancel(eventData)

    end

    def onDismiss(eventData)

    end
  end
end