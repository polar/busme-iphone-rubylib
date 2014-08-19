module Platform
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

      #   buf                         buf
      # (---  c1 ----------------- c2 ---)
      #          *      |
      #   H(c1-c3) *    | H*Sin(theta3)
      #              *  |
      #                c3

      a2 = (c1.y - c2.y)
      b2 = (c1.x - c2.x)
      theta1 = Math.atan2(a2, b2)
      a3 = (c1.y - c3.y)
      b3 = (c1.x - c3.x)
      theta2 =  Math.atan2(a3, b3)
      theta3 = theta2-theta1
      hc1c3 = Math.sqrt(a3*a3 + b3*b3)
      #
      # if the point is with in a buffer's radius of C1 then it is on the line,
      # Otherwise, its distance from C1 must be less than the distance to C2
      # plus the buffer, and its distance to the C1-C2 line must be less than the buffer.
      # Furthermore this calculation only works if difference in angles is less than PI/2.
      # If the difference in angles is greater than that, then the point is not near
      # the line, unless it was within the buffer radius of C1.
      #
      (Math.sin(theta3) * hc1c3).abs
    end

    def self.isOnLine(c1,c2,c3,buf)
      return offLine(c1,c2,c3) < buf
    end

    def self.isOnPath(points, point, buffer)
      if points.length > 0
        last = points[0]
      end
      for p in points
        if offLine(last, p, point) < buffer
          return true
        end
        last = p
      end
      return false
    end
  end
end