module Integration
  class Path
    include Api::Encoding
    attr_accessor :paths

    def propList
      ["@paths"]
    end

    def initWithCoder1(decoder)
      self.paths = decoder[:paths]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def encodeWithCoder1(encoder)
      encoder[:paths] = paths
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def initialize
      self.paths = []
    end

    def moveTo(x, y = nil)
      if x.is_a? Point
        self.paths << [x]
      else
        self.paths << [Point.new(x, y)]
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

    def to_s
      lens = paths.map {|x| x.length}
      "Integration::Path(#{paths.length} segments, #{lens.inspect})"
    end
  end
end