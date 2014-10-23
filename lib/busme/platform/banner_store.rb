module Platform
  class BannerStore
    include Api::Storage

    attr_accessor :banners

    def propList
      ["@banners"]
    end

    def initWithCoder1(decoder)
      self.banners = decoder[:banners]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def encodeWithCoder1(encoder)
      encoder[:banners] = banners
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

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