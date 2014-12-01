module Utils
  class PathUtils

    def self.rotate(point, pivot, theta, reuse = nil)
      out = reuse.nil? ? Integration::Point.new : reuse
      out.x = Math.cos(theta) * (point.x - pivot.x) - Math.sin(theta) * (point.y - pivot.y) + pivot.x
      out.y = Math.sin(theta) * (point.x - pivot.x) + Math.cos(theta) * (point.y - pivot.y) + pivot.y
      out
    end

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

    ##
    # The method defines a measure of the point c3 being off the line made by c1 to c2.
    # Point c3 is said to be within the bounds of c1 and c2 if its perpendicular height
    # line intersects with line in between c1 and c2.
    # If the point c3 is within the bounds of c1 and c2 then the offLine measurement is
    # the perpendicular distance from the line.
    # If point c3 is outside the bounds of c1 and c2, then the offLine measurement
    # is the height of an isosceles triangle (a=b,c) with c1 to c2 being the base (c), and keeping
    # the same perimeter distance, i.e. d(a) = d(b) = (d(c1,c3) + d(c3,c2))
    # This makes the measure more than its perpendicular distance from the line which would
    # intersect outside the bounds. For instance, if all coordinates had the same y, and
    # we had points c1(0,0) c2(1,0) c3(2,0), then the perpendicular distance from c1-c2 is 0, but
    # we are not between c1 and c2, so this function returns 1.4142135623730951 to signify the
    # off lineness
    #
    def self.offLine(c1, c2, c3)
      if c1.equals?(c2)
        return c1.equals?(c3) ? 0 : distance(c1, c3)
      end

      if c1.equals?(c3)
        return 0
      end

      a2 = (c2.y - c1.y)
      b2 = (c2.x - c1.x)
      theta1 = Math.atan2(a2, b2)

      # Rotate points around c1 to the horizontal line
      c2_1 = rotate(c2, c1, -theta1)
      c3_1 = rotate(c3, c1, -theta1)

      #   buf                          buf
      # (---  c1 ----------------- c2 ---)
      #          *      |
      #   H(c1-c3) *    | H*Sin(theta3)
      #              *  |
      #                c3
      if c1.x <= c3_1.x && c3_1.x <= c2_1.x
        a3 = (c3_1.y - c1.y)
        b3 = (c3_1.x - c1.x)
        theta3 =  Math.atan2(a3, b3)
        hc1c3 = Math.sqrt(a3*a3 + b3*b3)
        return (hc1c3 * Math.sin(theta3)).abs
      end

      hc1c2 = Math.sqrt(a2*a2 + b2*b2)
      hc1c3 = distance(c1, c3_1)
      hc2c3 = distance(c2_1, c3_1)

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

    def self.offRoute(points, point)
      max = 99999999999999
      if points.length > 0
        last = points[0]
      end
      for p in points
        off =  offLine(last, p, point)
        if off < max
          max = off
        end
        last = p
      end
      return max
    end

    def self.getRect(c1, c2)
      rect = Integration::Rect.new
      rect.left   = [c1.x, c2.x].min
      rect.top    = [c1.y, c2.y].min
      rect.right  = [c1.x, c2.x].max
      rect.bottom = [c1.y, c2.y].max
      rect
    end


  end
end