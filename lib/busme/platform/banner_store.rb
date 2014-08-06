module Platform
  class BannerStore
    def initialize
      @banners = {}
    end

    def getBanners
      @banners.values
    end

    def addBanner(info)
      @banners[info.id] = info if info
    end

    def removeBanner(key)
      @banners.delete(key)
    end
  end
end