module Integration
  class BoundingBoxE6
    include Api::Encoding
    attr_accessor :northE6
    attr_accessor :eastE6
    attr_accessor :southE6
    attr_accessor :westE6

    def propList
      %w(
    @northE6
    @eastE6
    @southE6
    @westE6
      )
    end
    def initWithCoder1(decoder)
      self.northE6 = decoder[:northE6]
      self.eastE6 = decoder[:eastE6]
      self.southE6 = decoder[:southE6]
      self.westE6 = decoder[:westE6]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def encodeWithCoder1(encoder)
      encoder[:northE6] = northE6
      encoder[:eastE6] = eastE6
      encoder[:southE6] = southE6
      encoder[:westE6] = westE6
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def north=(north)
      @northE6 = (north * 1E6).to_i
    end

    def north
      @northE6/1E6
    end

    def south=(south)
      @southE6 = (south * 1E6).to_i
    end

    def south
      @southE6/1E6
    end

    def east=(east)
      @eastE6 = (east * 1E6).to_i
    end

    def east
      @eastE6/1E6
    end

    def west=(west)
      @westE6 = (west * 1E6).to_i
    end

    def west
      @westE6/1E6
    end

    def initialize(*args)
      if args.length == 4
          initNESW(*args)
      else
        if args[0].is_a?(Array) && args[0].length == 4
          initNESW(*args[0])
        else
          raise "IllegalArgument"
        end
      end
    end

    def initNESW(northE6, eastE6, southE6, westE6)
      self.northE6 = northE6.to_i
      self.eastE6 = eastE6.to_i
      self.southE6 = southE6.to_i
      self.westE6 = westE6.to_i
    end

    def getCenter2
      x = 0
      y = 0
      z = 0
      [[north,west],[north,east],[south,east],[south,west]].each do |lon,lat|
        lon2 = (lon * Math::PI) /180.0
        lat2 = (lat * Math::PI) / 180.0
        x += Math.cos(lat2) * Math.cos(lon2)
        y += Math.cos(lat2) * Math.sin(lon2)
        z += Math.sin(lat2)
      end
      x = x/4
      y = y/4
      z = z/4
      lon3 = Math.atan2(y, x)
      hyp = Math.sqrt(x * x + y * y)
      lat3 = Math.atan2(z, hyp)
      GeoPoint.new((lat3 * 180 /Math::PI)*1E6, (lon3 * 180)/Math::PI * 1E6)
    end

    def getCenter
      GeoPoint.new((northE6 + southE6)/2, (eastE6 + westE6)/2)
    end

    def to_s
      "#{north},#{east},#{south},#{west}"
    end

  end
end