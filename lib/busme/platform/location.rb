module Platform
  class Location
    attr_accessor :name
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :speed
    attr_accessor :bearing
    attr_accessor :time

    def initialize(name, lon = 0.0, lat = 0.0)
      self.name      = name
      self.latitude  = lat
      self.longitude = lon
      self.time = Utils::Time.current
      self.speed = 0
      self.bearing = 0
    end

  end
end