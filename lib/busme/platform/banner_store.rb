module Platform
  class BannerStore
    include Api::Storage

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

    def preSerialize(api)

    end

    def postSerialize(api)

    end
  end
end