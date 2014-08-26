module Platform
  class LocationEventData
    attr_accessor :location
    attr_accessor :time

    def initialize(location, time = nil)
      self.location = location
      self.time = time || Time.now
    end
  end
end