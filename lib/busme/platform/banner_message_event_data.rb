module Platform
  class BannerMessageEventData < RequestState
    include BannerMessageConstants

    attr_accessor :thruUrl
    attr_accessor :resolve
    attr_accessor :banner_info
    attr_accessor :error

    def initialize(banner_info)
      super()
      self.banner_info = banner_info
    end

    def dup
      evd = BannerMessageEventData.new(banner_info)
      evd.state = state
      evd.resolve = resolve
      evd.thruUrl = thruUrl
      evd.error = error
      evd
    end
  end

end