module Api
  class JourneyPattern
    attr_accessor :id
    attr_accessor :path
    attr_writer   :projectedPath
    attr_writer   :distance

    def getPatternNameId()
      @name_id ||= NameId.new( [id, id, "P", "1"] )
    end

    def isReady()
      path != nil
    end

    def isReady?
      path != nil
    end

    def distance
      @distance ||= Platform::GeoPathUtils.getDistance(path) if path
    end

    def projectedPath
      @projectedPath ||= Utils::ScreenPathUtils.toProjectedPath(path)
    end

    def endPoint
      path && path.last
    end

    def loadParsedXML(tag)
      self.id = tag.attributes["id"]
      @distance = tag.attributes["distance"]
      @distance = @distance.to_f if @distance
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