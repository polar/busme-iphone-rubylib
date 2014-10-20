module Platform
  class LocatorGetEventData < Struct.new(:uiData, :lon, :lat, :buf, :get)

  end

  class LocatorDiscoverEventData < Struct.new(:uiData, :lon, :lat, :buf, :masters)

  end

  class FGBusmeLocatorController
    attr_accessor :api

    def initialize(discover_api)
      self.api = discover_api
      api.uiEvents.registerForEvent("Locator:onGet", self)
      api.uiEvents.registerForEvent("Locator:onDiscover", self)
      api.uiEvents.registerForEvent("Locator:onSelect", self)
    end

    def onBuspassEvent(event)
      case event.eventName
        when "Locator:onGet"
          onGet(event.eventData)
        when "Locator:onDiscover"
          onDiscover(event.eventData)
        when "Locator:onSelect"
          onSelect(event.eventData)
      end
    end

    def performGet(uiData, lon, lat, buf)
      evd = LocatorGetEventData.new(uiData, lon, lat, buf)
      api.bgEvents.postEvent("Locator:get", evd)
    end

    def performDiscover(uiData, lon, lat, buf)
      evd = LocatorDiscoverEventData.new(uiData, lon, lat, buf, nil)
      api.bgEvents.postEvent("Locator:discover", evd)
    end

    def performSelect(uiData, loc)
      api.bgEvents.postEvent("Locator:select", loc)
    end

    def onGet(eventData)

    end

    def onDiscover(eventData)

    end

    def onSelect(eventData)

    end

  end
end