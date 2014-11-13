module Platform
  class LocationController
    attr_accessor :api
    attr_accessor :masterController
    def initialize(api, controller)
      self.api = api
      self.masterController = controller
      api.bgEvents.registerForEvent("LocationUpdate", self)
    end

    def onBuspassEvent(event)
      case event.eventName
        when "LocationUpdate"
          onLocationUpdate(event.eventData)
      end
    end

    def onLocationUpdate(eventData)
      location = eventData.location
      masterController.bannerBasket.onLocationUpdate(location)
      masterController.markerBasket.onLocationUpdate(location)
    end
  end
end