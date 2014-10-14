module Platform
  class BusmeLocatorController
    attr_accessor :api

    def initialize(discover_api)
      self.api = discover_api
      api.bgEvents.registerForEvent("Locator:get", self)
      api.bgEvents.registerForEvent("Locator:discover", self)
    end

    def onBuspassEvent(event)
      case event.eventName
        when "Locator:get"
          d = event.eventData
          doGet(d)
        when "Locator:discover"
          d = event.eventData
          doDiscover(d)
        end
    end

    def doDiscover(eventData)
      masters = api.discover(eventData.lon, eventData.lat, eventData.buf)
      eventData.masters = masters
      api.uiEvents.postEvent("Locator:onDiscover", eventData)
    end

    def doGet(eventData)
      get = api.get
      eventData.get = get
      api.uiEvents.postEvent("Locator:onGet", eventData)
    end
  end
end