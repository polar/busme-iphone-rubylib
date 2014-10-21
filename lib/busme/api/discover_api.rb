module Api
  class DiscoverAPI  < APIBase

    def get
      return false
    end

    def discover(lon, lat, buffer)
      return false
    end

    def discoverWithArgs(args)
      discover(args[:lon], args[:lat], args[:buf])
    end
  end
end