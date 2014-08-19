module Platform
  class Rect
    attr_accessor :left
    attr_accessor :top
    attr_accessor :right
    attr_accessor :bottom

    def initialize(left = 0, top = 0, right = 0, bottom = 0)
      set(left, top, right, bottom)
    end

    def set(left, top, right, bottom)
      self.left = left
      self.top = top
      self.right = right
      self.bottom = bottom
    end

    def dup
      Rect.new(left, top, right, bottom)
    end

    def equals?(rect)
      left == rect.left && top == rect.top && right == rect.top && bottom == rect.bottom
    end

    def left=(x)
      @left = x.to_i
    end

    def right=(x)
      @right = x.to_i
    end

    def top=(y)
      @top = y.to_i
    end

    def bottom=(y)
      @bottom = y.to_i
    end

    def width
      right - left
    end

    def height
      bottom - top
    end

    def centerX
      (exactCenterX).to_i
    end

    def exactCenterX
      left + width/2.0
    end

    def centerY
      (exactCenterY).to_i
    end

    def exactCenterY
      top + height/2.0
    end

    def center
      Point.new(centerX, centerY)
    end

    def offset(dx, dy)
      self.left += dx
      self.right += dx
      self.top += dy
      self.bottom += dy
    end

    def offsetTo(newX, newY)
      w = width
      h = height
      self.left = newX
      self.top = newY
      self.right = left + w
      self.bottom = top + h
    end

    def containsXY(x, y)
      left <= x && x <= right && top <= y && y <= bottom
    end

    def contains(l, t, r, b)
      left <= l && top <= t && r <= right && b <= bottom
    end

    def containsRect(rect)
      left <= rect.left && top <= rect.top && rect.right <= right && rect.bottom <= bottom
    end

    def intersect(l, t, r, b)
      !(left > r || right < l || top > b || bottom < t)
    end

    def intersectRect(rect)
      !(left > rect.right || right < rect.left || top > rect.bottom || bottom < rect.top)
    end

    def resizeCenter(dw, dh)
      self.left -= dw/2.0
      self.right += dw/2.0
      self.top -= dh/2.0
      self.bottom += dh/2.0
    end



  end
end