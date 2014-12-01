module Platform
  class LocationController
    attr_accessor :api
    attr_accessor :masterController
    attr_accessor :lastKnownLocation

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

    def currentLocation
      # TODO If it's not current don't return it.
      lastKnownLocation
    end

    def onLocationUpdate(eventData)
      puts "LocationController::onLocationUpdate(#{eventData.location.inspect})"
      location = eventData.location
      api.lastKnownLocation = self.lastKnownLocation = location
      masterController.bannerBasket.onLocationUpdate(location)
      masterController.markerBasket.onLocationUpdate(location)
      masterController.masterMessageBasket.onLocationUpdate(location)
      needsVisualUpdate = masterController.journeyVisibilityController.onCurrentLocationChanged(location)
      if needsVisualUpdate
        api.uiEvents.postEvent("VisibilityChanged")
      end
    end
  end
end