module Utils
  class PathUtils
    def self.distance(pointA, pointB)
      a = (pointA.y - pointB.y).abs
      b = (pointA.x - pointB.x).abs
      c = Math.sqrt(a*a + b*b)
    end

    def self.pathDistance(points)
      if points.length > 0
        last = points.first
      end
      d = 0
      for p in points
        d += distance(last,p)
        last = p
      end
      d
    end


    def self.offLine(c1, c2, c3)
      if c1.equals?(c2)
        return c1.equals?(c3) ? 0 : distance(c1, c3)
      end

      if c1.equals?(c3)
        return 0
      end

      #   buf                          buf
      # (---  c1 ----------------- c2 ---)
      #          *      |
      #   H(c1-c3) *    | H*Sin(theta3)
      #              *  |
      #                c3

      hc2c3 = distance(c3, c2)
      hc1c2 = distance(c1,c2)
      hc1c3 = distance(c1,c3)
      #
      # in the case   c
      #      c1-----------------c2
      # a   *                *
      #    *          *
      #   *    *    b
      #  *
      # c3
      # We measure by making it an (a=b,c) isosceles triangle with the same perimeter. That is with sides
      # of a = b = (H(c1,c3) + H(c2,c3))/2, and c = H(c1,c2) then measure the height
      # by SQRT( a*a - (c/2)*(c/2)
      #
      a = b = (hc1c3 + hc2c3)/2.0
      c = hc1c2
      c_2 = c/2.0
      off = Math.sqrt(a*a - c_2*c_2)
    end

    def self.isOnLine(c1,c2,c3,buf)
      return offLine(c1,c2,c3) < buf
    end

    def self.isOnPath(points, point, buffer)
      if points.length > 0
        last = points[0]
      end
      for p in points
        off =  offLine(last, p, point)
        if off < buffer
          return true
        end
        last = p
      end
      return false
    end
  end
end