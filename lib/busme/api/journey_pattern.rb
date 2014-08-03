module Api
  class JourneyPattern
    attr_accessor :id
    attr_accessor :path
    attr_writer   :distance

    def getPatternNameId()
      @name_id ||= NameId.new( [id, id, "P", "1"] )
    end

    def isReady()
      path != nil
    end

    def projectedPath
      # Needs to be implemented for the specific UI
      raise "NotImplemented"
    end

    def distance
      @distance ||= Platform::GeoPathUtils.getDistance(path) if path
    end

    def loadParsedXML(tag)
      self.id = tag.attributes["id"]
      self.distance = tag.attributes["distance"]
      if tag.childNodes
        for jps in tag.childNodes do
          if "jps" == jps.name.downcase
            self.path = parsePath(jps)
            return path
          end
        end
      end
    end

    private

    def parsePath(jps)
      path = []
      for jp in jps.childNodes do
        lat = jp.attributes["lat"].to_f
        lon = jp.attributes["lon"].to_f
        gp = Integration::GeoPoint.new((lat * 1E6).to_i, (lon * 1E6).to_i)
        path << gp
      end
      path
    end

  end
end