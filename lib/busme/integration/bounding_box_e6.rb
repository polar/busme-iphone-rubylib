module Integration
  class BoundingBoxE6
    attr_accessor :northE6
    attr_accessor :eastE6
    attr_accessor :southE6
    attr_accessor :westE6

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

    def initialize(northE6, eastE6, southE6, westE6)
      self.northE6 = northE6.to_i
      self.eastE6 = eastE6.to_i
      self.southE6 = southE6.to_i
      self.westE6 = westE6.to_i
    end

  end
end