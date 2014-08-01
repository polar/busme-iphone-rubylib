module Platform
  class BannerBasket
    attr_accessor :bannerStore
    attr_accessor :bannerController
    attr_accessor :activityAPI
    attr_accessor :banners

    def initialize(api, store, controller)
      self.activityAPI = api
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

    def onLocationUpdate(location)
      point = GeoCalc.toGeoPoint(location)
      now = Time.now
      for banner in getBanners do
        dist = point.distanceTo(banner.point)
        if dist < banner.radius
          if banner.shouldBeSeen(now)
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