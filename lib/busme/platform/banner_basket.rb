module Platform
  class BannerBasket
    attr_accessor :bannerStore
    attr_accessor :bannerController
    attr_accessor :banners

    def initialize(store, controller)
      self.bannerStore = store
      self.bannerController = controller
      self.banners = []
    end

    def getBanners
      bannerStore.getBanners
    end

    def addBanner(banner_info)
      bannerStore.addBanner(banner_info)
    end

    def removeBanner(key)
      bannerStore.removeBanner(key)
    end

    def onLocationUpdate(location, now = nil)
      point = GeoCalc.toGeoPoint(location)
      now = Time.now if now.nil?
      for banner in getBanners do
        dist = GeoCalc.getGeoDistance(point, banner.point)
        if dist < banner.radius
          if banner.shouldBeSeen?(now)
            # display a marker
            bannerController.addBanner(banner)
          end
        else
          bannerController.removeBanner(banner)
        end
      end
    end

  end
end