module Platform
  class BannerStore
    attr_accessor :banners
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