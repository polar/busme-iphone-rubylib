module Platform
  class GeoCalc
    LAT_PER_FOOT =  2.738129E-6
    LON_PER_FOOT = 2.738015E-6
    FEET_PER_KM = 3280.84
    EARTH_RADIUS_FEET = 6371.009 * FEET_PER_KM
    DEFAULT_PRECISION = 1E6

    def self.to_radians(deg)
      deg * Math::PI / 180.0
    end

    def self.to_degrees(rad)
      rad * (180.0 / Math::PI)
    end

    def self.to_sign(n)
      n < 0 ? -1 : n == 0 ? 0 : 1
    end

    def self.equalCoordinates(c1, c2, prec = DEFAULT_PRECISION)
      result = (c1.longitude*prec).floor == (c2.longitude*prec).floor &&
          (c1.latitude*prec).floor == (c2.latitude*prec).floor
      return result
    end

    def self.getCentralAngle1(c1, c2)
      dlon = to_radians(c1.longitude - c2.longitude)
      a = Math.cos(to_radians(c2.latitude * Math.sin(dlon)))
      b = Math.cos(to_radians(c2.latitude))*Math.sin(to_radians(c2.latitude))*Math.cos(to_radians(c2.latitude))*Math.cos(dlon)
      c = Math.sin(to_radians(c2.latitude))*Math.cos(to_radians(c2.latitude))*Math.cos(to_radians(c2.latitude))*Math.cos(dlon)

      result = Math.atan2(Math.sqrt(a*a + b*b), c)
      return result
    end

    def self.getCentralAngleVicenty(c1, c2)
      dlon = to_radians(c1.longitude - c2.longitude)
      a = Math.cos(to_radians(c2.latitude * Math.sin(dlon)))
      b = Math.cos(to_radians(c2.latitude))*Math.sin(to_radians(c2.latitude)) - Math.sin(to_radians(c1.latitude))*Math.cos(to_radians(c2.latitude))*Math.cos(dlon)
      c = Math.sin(to_radians(c2.latitude))*Math.sin(to_radians(c2.latitude)) + Math.sin(to_radians(c1.latitude))*Math.cos(to_radians(c2.latitude))*Math.cos(dlon)

      result = Math.atan2(Math.sqrt(a*a + b*b), c)
      return result
    end

    def self.getCentralAngleHaversine(c1, c2)
      dlon = to_radians(c2.longitude - c1.longitude)
      dlat = to_radians(c2.latitude - c1.latitude)
      lat1 = to_radians(c1.latitude)
      lat2 = to_radians(c2.latitude)

      a = Math.sin(dlat/2.0) * Math.sin(dlat/2.0) + Math.sin(dlon/2.0) * Math.sin(dlon/2.0) * Math.cos(lat1) * Math.cos(lat2)
      angle = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      return angle
    end

    def self.getCentralAngle(c1, c2)
      getCentralAngleHaversine(c1,c2)
    end

    # Returns the distance between two locations in feet.
    def self.getGeoDistance(c1, c2)
      if equalCoordinates(c1,c2)
        return 0.0
      end
      ca = getCentralAngle(c1, c2)
      dist = EARTH_RADIUS_FEET * ca
      result = dist.abs
      return result
    end

    def self.getGeoAngle(c1, c2)
      x = c2.longitude - c1.longitude
      y = c2.latitude - c1.latitude
      y = y <= -180 ? y + 360 : y
      y = y >= 180 ? y - 360 : y

      nw = getLocation(c2.longitude, c1.latitude)

      ca1 = getCentralAngle(c1, nw)
      dist1 = EARTH_RADIUS_FEET * ca1 * to_sign(x)
      ca2 = getCentralAngle(c2, nw)
      dist2 = EARTH_RADIUS_FEET * ca2 * to_sign(y)
      result = Math.atan2(dist2, dist1)
      return result
    end

    def self.getBearing(gp1, gp2)
      lat1 = GeoCalc.to_radians(gp1.latitude)
      long1 = GeoCalc.to_radians(gp1.longitude)
      lat2 = GeoCalc.to_radians(gp2.latitude)
      long2 = GeoCalc.to_radians(gp2.longitude)
      delta_long = long2 - long1
      a = Math.sin(delta_long) * Math.cos(lat2)
      b = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(delta_long)
      bearing = GeoCalc.to_degrees(Math.atan2(a,b))
      bearing_normalized = (bearing + 360) % 360
      return bearing_normalized
    end

    # Returns true if point is on line within the buffer (in feet)
    def self.isOnLine(c1, c2, buffer, c3)
      c1 = toLocation(c1)
      c2 = toLocation(c2)
      c3 = toLocation(c3)

      theta1 = getGeoAngle(c1, c2)
      theta2 = getGeoAngle(c1, c3)
      theta3 = theta2-theta1

      hclc3 = getGeoDistance(c1,c3)
      hclc2 = getGeoDistance(c1,c2)

      result = hclc3 < buffer || theta3.abs < Math::PI/2.0 &&
          hclc3 <= hclc2 + buffer/2.0 && (Math.sin(theta3) * hclc3).abs <= buffer/2.0
      return result
    end

    def self.getLocation(longitude, latitude)
      loc = Location.new("Yomama")
      loc.latitude = latitude
      loc.longitude = longitude
      return loc
    end

    def self.toLocation(gp)
      if gp.is_a? Integration::GeoPoint
        getLocation(gp.longitude, gp.latitude)
      else
        gp
      end
    end

    def self.isOnPath(path, buffer, c3)
      p1 = path[0]
      i = 1
      while i < path.length
        p2 = path[i]
        if isOnLine(p1, p2, buffer, c3)
          return true
        end
        p1 = p2
        i += 1
      end
      return false
    end

    def self.pathDistance(path)
      dist = 0.0
      p1 = toLocation(path[0])
      i = 1
      while i < path.length
        p2 = toLocation(path[i])
        dist += getGeoDistance(p1, p2)
        p1 = p2
        i += 1
      end
      return dist
    end

    def self.toGeoPoint(location)
      gp = Integration::GeoPoint.new(location.latitude * 1E6, location.longitude * 1E6)
    end
  end
end