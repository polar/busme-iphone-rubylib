module Utils
  class Time < ::Time

    def self.current
      self.now
    end

    def self.parseTimeInZone(str, zone = nil)
     #puts "For purposes of testing we ignore the zone" if zone
      parse(str)
    end
  end
end