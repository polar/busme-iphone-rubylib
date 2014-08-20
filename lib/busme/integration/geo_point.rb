module Integration
  class GeoPoint
    DEG2RAD = (Math::PI / 180.0)
    LAT_PER_FOOT =  2.738129E-6
    LON_PER_FOOT = 2.738015E-6
    FEET_PER_KM = 3280.84
    EARTH_RADIUS_FEET = 6371.009 * FEET_PER_KM

    attr_reader :longitudeE6
    attr_reader :latitudeE6

    def initialize(latE6 = 0, lonE6 = 0)
      self.latitudeE6 = latE6
      self.longitudeE6 = lonE6
    end

    def longitude
      longitudeE6 / 1E6
    end

    def longitude=(lon)
      self.longitudeE6 = (lon * 1E6).to_i
    end

    def longitudeE6=(lon)
      @longitudeE6 = lon.to_i
    end

    def latitude
      latitudeE6 / 1E6
    end

    def latitudeE6=(lat)
      @latitudeE6 = lat.to_i
    end

    def latitude=(lat)
      self.latitudeE6 = (lat * 1E6).to_i
    end

    def distanceTo(gp)
      a1 = DEG2RAD * latitude
      a2 = DEG2RAD * longitude
      b1 = DEG2RAD * gp.latitude
      b2 = DEG2RAD * gp.longitude

      cosa1 = Math.cos(a1)
      cosb1 = Math.cos(b1)

      t1 = cosa1 * Math.cos(a2) * cosb1 * Math.cos(b2)
      t2 = cosa1 * Math.sin(a2) * cosb1 * Math.sin(b2)
      t3 = Math.sin(a1) * Math.sin(b1)
      tt = Math.acos(t1 + t2 + t3)

      EARTH_RADIUS_FEET * tt
    end

    def bearingTo(gp)
      lat1 = GeoCalc.to_radians(latitude)
      long1 = GeoCalc.to_radians(longitude)
      lat2 = GeoCalc.to_radians(gp.latitude)
      long2 = GeoCalc.to_radians(gp.longitude)
      delta_long = long2 - long1
      a = Math.sing(delta_long) * Math.cos(lat2)
      b = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(delta_long)
      bearing = GeoCalc.to_degrees(Math.atan2(a,b))
      bearing_normalized = (bearing + 360) % 360
      return bearing_normalized
    end

    def hash
      [latitudeE6,longitudeE6].hash
    end

    def eql?(other)
      other.class == self.class && Platform::GeoCalc.equalCoordinates(self,other)
    end
  end
end
