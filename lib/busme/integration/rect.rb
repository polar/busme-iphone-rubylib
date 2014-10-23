module Integration
  class Rect
    attr_accessor :left
    attr_accessor :top
    attr_accessor :right
    attr_accessor :bottom

    def propList
      %w(
    @left
    @top
    @right
    @bottom
      )
    end
    def initWithCoder1(decoder)
      self.left = decoder[:left]
      self.top = decoder[:top]
      self.right = decoder[:right]
      self.bottom = decoder[:bottom]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def encodeWithCoder1(encoder)
      encoder[:left] = left
      encoder[:top] = top
      encoder[:right] = right
      encoder[:bottom] = bottom
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def self.initWithLineCoords(x1,y1,x2,y2)
      r = self.new
      r.left = [x1,x2].min
      r.top = [y1,y2].max
      r.right = [x1,x2].max
      r.bottom = [y1,y2].min
      r
    end

    def initialize(left = 0, top = 0, right = 0, bottom = 0)
      set(left, top, right, bottom)
    end

    def set(left, top, right, bottom)
      self.left = left.to_f
      self.top = top.to_f
      self.right = right.to_f
      self.bottom = bottom.to_f
    end


    def dup
      Rect.new(left, top, right, bottom)
    end

    def equals?(rect)
      left == rect.left && top == rect.top && right == rect.top && bottom == rect.bottom
    end

    def left=(x)
      @left = x.to_f
    end

    def right=(x)
      @right = x.to_f
    end

    def top=(y)
      @top = y.to_f
    end

    def bottom=(y)
      @bottom = y.to_f
    end

    def width
      right - left
    end

    def height
      top - bottom
    end

    def centerX
      (exactCenterX).to_f
    end

    def exactCenterX
      left + width/2.0
    end

    def centerY
      (exactCenterY).to_f
    end

    def exactCenterY
      bottom + height/2.0
    end

    def center
      Point.new(centerX, centerY)
    end

    def area
      height * width
    end

    def offset(dx, dy)
      self.left += dx.to_f
      self.right += dx.to_f
      self.top += dy.to_f
      self.bottom += dy.to_f
    end

    def offsetTo(newX, newY)
      w = width
      h = height
      self.left = newX.to_f
      self.top = newY.to_f
      self.right = left + w
      self.bottom = top + h
    end

    def containsXY(x, y)
      left <= x && x <= right && bottom <= y && y <= top
    end

    def contains(l, t, r, b)
      l >= left && t <= top && r <= right && b >= bottom
    end

    def containsRect(rect)
      rect.left >= left && rect.top <= top && rect.right <= right && rect.bottom >= bottom
    end

    def intersect(l, t, r, b)
      rect = Rect.new(l,t,r,b)
      intersectRect(rect)
    end

    # Intersects a rect if it contains a corner
    def intersectRect(rect)
      rect.containsXY(left,top) ||
        rect.containsXY(right,top) ||
        rect.containsXY(left,bottom) ||
        rect.containsXY(right,bottom) ||
        self.containsXY(rect.left,rect.top) ||
        self.containsXY(rect.right,rect.top) ||
        self.containsXY(rect.left, rect.bottom) ||
        self.containsXY(rect.right,rect.bottom)
    end

    def resizeCenter(dw, dh)
      self.left -= (dw/2.0).to_f
      self.right += (dw/2.0).to_f
      self.top -= (dh/2.0).to_f
      self.bottom += (dh/2.0).to_f
    end

    def to_s
      "Rect(#{left},#{top},#{right},#{bottom})"
    end



  end
end