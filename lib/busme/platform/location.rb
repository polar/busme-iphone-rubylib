module Platform
  class Location
    attr_accessor :name
    attr_accessor :latitude
    attr_accessor :longitude

    def initialize(name)
      self.name      = name
      self.latitude  = 0.0
      self.longitude = 0.0
    end

  end
end