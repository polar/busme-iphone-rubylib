module Integration
  class Point
    attr_accessor :x
    attr_accessor :y

    def propList
      %w(@x @y)
    end

    def initWithCoder1(decoder)
      self.x = decoder[:x]
      self.y = decoder[:y]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def encodeWithEncoder1(encoder)
      encoder[:x] = x
      encoder[:y] = y
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def initialize(x = 0, y = 0)
      set(x, y)
    end

    def set(x, y)
      self.x = x
      self.y = y
    end

    def x=(x)
      @x = x.to_i
    end

    def y=(y)
      @y = y.to_i
    end

    def offset(xoff, yoff)
      self.x += xoff
      self.y += yoff
    end

    def equals?(point)
      point.x == x && point.y == y
    end
    def to_s
      "P(#{x},#{y})"
    end
  end
end