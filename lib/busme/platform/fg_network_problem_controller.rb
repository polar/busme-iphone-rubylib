module Platform

  class FGNetworkProblemController
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("NetworkProblem", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a? Api::NetworkProblemEventData
        present(eventData)
      end

    end

    def present(eventData)
      # Make a Network Problem Dialog appear
    end

    def dismiss(eventData)
      # Dismiss Network Problem Dialog appear

    end

    # The usual three buttons of an alert dialog

    def onOK(eventData)
      dismiss(eventData)
    end

    def onCancel(eventData)
      dismiss(eventData)
    end

    def onDismiss(eventData)
      dismiss(eventData)
    end
  end
end