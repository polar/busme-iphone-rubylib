module Platform
  class GeoPathUtils
    LAT_PER_FOT = 2.738129E-6
    LON_PER_FOOT = 2.738015E-6
    FEET_PER_KM = 3280.84
    EARTH_RADIUS_FEET = 6371.009 * FEET_PER_KM

    def self.getCentralAngle(c1, c2)
      GeoCalc.getCentralAngle(c1, c2)
    end

    def self.getGeoAngle(c1, c2)
      GeoCalc.getGeoAngle(c1, c2)
    end

    def self.isOnLine(c1, c2, buffer, c3)
      GeoCalc.isOnLine(c1, c2, buffer, c3)
    end

    def self.isOnPath(path, point, buffer)
      GeoCalc.isOnPath(path, buffer, point)
    end

    def self.getGeoDistance(c1, c2)
      GeoCalc.getGeoDistance(c1, c2)
    end

    def self.getDistance(path)
      GeoCalc.pathDistance(path)
    end

    def self.offPath(path, point)
      max = EARTH_RADIUS_FEET * EARTH_RADIUS_FEET * Math::PI
      last = nil
      if path.length > 0
        last = path[0]
      end
      for p in path
        off =  GeoCalc.offLine(last, p, point)
        if off < max
          max = off
        end
        last = p
      end
      return max
    end

    def self.whereOnPath(path, point, buffer)
      results = []
      distance = 0.0
      p1 = path[0]
      i = 0
      for p2 in path.drop(1) do
        if isOnLine(p1, p2, buffer, point)
          dist = GeoCalc.getGeoDistance(p1, point)
          bearing = GeoCalc.getBearing(point, p2)
          results << DGeoPoint.new(point, distance + dist, bearing)
          distance += GeoCalc.getGeoDistance(p1, p2)
        else
          distance += GeoCalc.getGeoDistance(p1, p2)
        end
        p1 = p2
        i += 1
      end
      results
    end

    def self.rectForPath(path)
      right = left = path[0].longitude
      top = bottom = path[0].latitude
      for i in 1..path.size-1
        # TODO This is wrong if we span the date line
        left = [left, path[i].longitude].min
        right = [right, path[i].longitude].max
        top = [top, path[i].latitude].max
        bottom = [bottom, path[i].latitude].min
      end
      Integration::Rect.new(left, top, right, bottom)
    end
  end
end