module Platform
  class DGeoPoint
    attr_accessor :geo_point
    attr_accessor :bearing
    attr_accessor :distance

    def initialize(point, distance, bearing)
      self.geo_point = point
      self.distance = distance
      self.bearing = bearing
    end
  end
end
