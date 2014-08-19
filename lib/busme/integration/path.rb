module Integration
  class Path
    attr_accessor :paths

    def initialize
      self.paths = []
    end

    def moveTo(x, y = nil)
      if x.is_a? Point
        paths << [x]
      else
        paths << [Point.new(x, y)]
      end
    end

    def lineTo(x, y = nil)
      point = x.is_a?(Point) ? x : Point.new(x, y)
      path = paths.last
      if path.nil?
        moveTo(point)
      else
        last = path.last
        path << point if last.nil? || point.x != last.x || point.y != last.y
      end
    end
  end
end