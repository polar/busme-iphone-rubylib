module Platform
  class BannerPresentEventData
    attr_accessor :banner_info

    def initialize(banner_info)
      self.banner_info = banner_info
    end
  end
end