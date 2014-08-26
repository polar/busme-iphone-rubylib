module Platform
  class BannerBasketEventController
    attr_accessor :api
    attr_accessor :bannerBasket

    def initialize(api, basket)
      self.api = api
      self.bannerBasket = basket
      api.bgEvents.registerForEvent("BannerBasket:AddBanner", self)
      api.bgEvents.registerForEvent("BannerBasket:RemoveBanner", self)
      api.bgEvents.registerForEvent("LocationUpdate", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      case event.eventName
        when "BannerBasket:AddBanner"
          onAddBanner(eventData)
        when "BannerBasket::RemoveBanner"
          onRemoveBanner(eventData)
        when "LocationUpdate"
          onLocationUpdate(eventData)
      end
    end

    def onAddBanner(eventData)
      bannerBasket.addBanner(eventData.banner_info)
    end

    def onRemoveBanner(eventData)
      bannerBasket.removeBanner(eventData.banner_info)
    end

    def onLocationUpdate(eventData)
      bannerBasket.onLocationUpdate(eventData.location, eventData.time)
    end
  end
end