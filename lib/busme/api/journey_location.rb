module Api
  class JourneyLocation
    attr_accessor :id
    attr_accessor :lat
    attr_accessor :lon
    attr_accessor :dir
    attr_accessor :reported_time
    attr_accessor :recorded_time
    attr_accessor :timediff
    attr_accessor :onroute
    attr_accessor :reported
    attr_accessor :distance
    attr_accessor :time

    def loadParsedXMLTag(tag)
      self.id = tag.attributes["id"]
      self.lat = tag.attributes["lat"].to_f
      self.lon = tag.attributes["lon"].to_f
      self.dir = tag.attributes["dir"].to_f
      self.reported = tag.attributes["reported"] == "true"
      self.reported_time = Time.at(tag.attributes["reported_time"].to_i)
      self.recorded_time = Time.at(tag.attributes["recorded_time"].to_i)
      self.distance = tag.attributes["distance"].to_f
      self.onroute = tag.attributes["onroute"] == "true"
    end
  end
end