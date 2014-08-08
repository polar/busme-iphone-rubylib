module Api
  class Route
    attr_accessor :busAPI
    attr_accessor :name
    attr_accessor :type
    attr_accessor :id
    attr_accessor :code
    attr_accessor :direction
    attr_accessor :vid
    attr_accessor :workingVid
    attr_accessor :timeless
    attr_accessor :sort
    attr_accessor :version
    attr_accessor :nw_lon
    attr_accessor :nw_lat
    attr_accessor :se_lon
    attr_accessor :se_lat
    attr_accessor :locationRefreshRate
    attr_accessor :startOffset
    attr_accessor :duration
    attr_accessor :startTime
    attr_accessor :endTime
    attr_accessor :schedStartTime
    attr_accessor :actualStartTime
    attr_accessor :patternid
    attr_accessor :patternids
    attr_accessor :lastKnownLocation
    attr_accessor :lastKnownTime
    attr_accessor :lastKnownTimediff
    attr_accessor :lastKnownDistance
    attr_accessor :lastKnownDirection
    attr_accessor :onRoute
    attr_accessor :timeZone
    attr_accessor :reported

    attr_accessor :journeyStore

    def preSerialize
      @journeyStore = nil
      @paths = nil
      @projectedPaths = nil
    end

    def postSerialize(api)
      self.journeyStore = api.journeyStore
    end

    def getJourneyPattern(id)
      journeyStore.getPattern(id)
    end

    def journeyPatterns
      patternids.map {|x| journeyStore.getPattern(id) }.compact
    end

    def initialize
      self.version = -1
      self.locationRefreshRate = 10 # seconds
    end

    def postSerialize(api)
      self.busAPI = api
    end

    def getNameId
      @nameid ||= NameId.new([name, id, isJourney? ? "J" : "R", version.to_s])
    end

    def updateStartTimes(nameid)
      self.actualStartTime = nameid.time_start
      self.schedStartTime = nameid.sched_time_start
    end

    def paths
      @paths ||= journeyPatterns.map {|x| x.path }
    end

    def projectedPaths
      @projectedPaths ||= journeyPatterns.map {|x| x.projectedPaths}
    end

    def getPathCount
      paths.length
    end

    def getPath(i)
      paths[i]
    end

    def isJourney?
      "journey" == type
    end

    def isPattern?
      "pattern" == type
    end

    def isActiveJourney?
      isJourney? && lastKnownLocation
    end

    def isStartingJourney?(threshold = nil, time = nil)
      threshold = busAPI.activeStartDisplayThreshold if threshold.nil?
      time = Time.now if time.nil?
    end

    def isNotYetStartingJourney?
      if isJourney?
        startMeasure = getStartingMeasure(busAPI.activeStartDisplayThreshold, Time.now)
        return startMeasure < 0.0
      end
      false
    end

    def isRouteDefinition?
      "route" == type
    end

    # Day should have the correct timezone set
    def getStartTime
      if schedStartTime
        Time.at(schedStartTime)
      else
        Time.parse("0:00") + startOffset * 60
      end

    end
    def getEndTime
      getStartTime + duration * 60
    end

    def isActive?
      isActiveJourney? && ! isFinished? && isStarting?
    end

    def isStarting?
      isStartingJourney?
    end

    def isTimeless?
      timeless
    end

    def isFinished?
      loc = lastKnownLocation
      distance = lastKnownDistance
      path_distance = journeyPatterns[0].distance
      dist_from_last = journeyPatterns[0].endPoint.distanceTo(loc)
      path_distance - distance < 10 && dist_from_last < 3 # feet
    end

    def getZoomCenter
      if @zoomcenter.nil?
        lat = se_lat + (nw_lat - se_lat)/2.0
        dx = nw_lon - se_lon
        lon = se_lon + dx/2
        lon = lon < -180 ? lon+360 : lon
        lon = lon > 180 ? lon-360 : lon
        @zoomcenter = Platform::GeoPoint.new((lat*1E6).to_i, (lon*1E6).to_i)
      end
      @zoomcenter
    end

    def getLongitudeSpanE6
      dx = (nw_lon - se_lon).abs
      dx = dx > 180 ? 360-x : dx
      dx = dx * 1.1 # padding
      return (dx*1E6).to_i
    end

    def getLatitudeSpanE6
      dy = (nw_lat - se_lat).abs
      dy = dy * 1.2 # padding
      return (dy*1E6).to_i
    end

    def isNearRoute(point, d)
      isNearRoute = false
      for jp in journeyPatterns do
        path = jp.path
        isNearRoute ||= Platform::GeoPathUtils.isOnPath(path, point, d)
        if isNearRoute
          break
        end
      end
      isNearRoute
    end

    def whereOnPaths(point, buffer)
      result = []
      for jp in journeyPatterns do
        path = jp.path
        possibles = Platform::GeoPathUtils.whereOnPath(path, point, buffer)
        result += possibles
      end
      result
    end

    def getNearestStartingPoint(point, feet)
      nearest = nil
      for jp in journeyPatterns do
        path = jp.getPath()
        dist = Platform::GeoPathUtils.getGeoDistance(point, path[0])
        if dist < feet
          if nearest.nil?
            nearest = path[0]
          elsif Platform::GeoPathUtils.getGeoDistance(path[0], point) < Platform::GeoPathUtils.getGeoDistance(nearest, point)
            nearest = path[0]
          end
        end
      end
      nearest
    end

    def getStartingPoint
      journeyPatterns[0].path[0] if journeyPatterns[0]
    end

    def getStartingMeasure(threshold = nil, time = nil)
      threshold = busAPI.activeStartDisplayThreshold if threshold.nil?
      time = Time.now if time.nil?
      timediff = getStartTime - time;
      ret = 1.0
      diff = 0
      distance = -1
      loc = lastKnownLocation
      if loc
        start = getStartingPoint
        distance = start.distanceTo(loc)
        if (0 <= distance && distance < 5)
          if (0 <= timediff && timediff <= threshold)
            diff = threshold - timediff
            ret = (diff*diff)/(threshold*threshold)
          else
            ret = -1.0
          end
        else
          ret = 1.1
        end
      else
        if 0 <= timediff && timediff <= threshold
          diff = threshold - timediff
          ret = (diff*diff)/(threshold*threshold)
        else
          ret = -1.0
        end
      end
      return ret
    end

    def loadParsedXML(tag)
      self.type = tag.attributes["type"]
      self.id = tag.attributes["id"]
      self.name = tag.attributes["name"]
      self.direction = tag.attributes["dir"]
      self.code = tag.attributes["routeCode"]
      self.version = tag.attributes["version"].to_i
      self.patternid = tag.attributes["patternid"]
      self.vid = tag.attributes["vid"]
      self.duration = tag.attributes["duration"].to_f
      self.sort = tag.attributes["sort"].to_f
      self.locationRefreshRate = tag.attributes["locationRefreshRate"]
      self.timeZone = tag.attributes["timeZone"]
      self.schedStartTime = tag.attributes["schedStartTime"]
      self.nw_lon = tag.attributes["nw_lon"]
      self.nw_lat = tag.attributes["nw_lat"]
      self.se_lon = tag.attributes["se_lon"]
      self.se_lat = tag.attributes["se_lat"]
      self.timeless = tag.attributes["timeless"]
      self.startOffset = tag.attributes["startOffset"].to_f
      self.patternids = tag.attributes["patternids"].split(",") if tag.attributes["patternids"]
    end

    def to_s
      if isRouteDefinition?
        s = "Route(#{code}, #{name}, pc=#{path.size}, id=#{id}"
      end
      if isJourney?
        s = "Journey(#{code}, #{name}, id=#{id}, ver=#{version}, patid=#{patternid}"
        if isActive?
          s += "Active,"
        end
        if isActiveJourney?
          s += "ActiveJourney,"
        end
        if isStarting?
          s += "Starting,"
        end
        if isNotYetStartingJourney?
          s += "IsNotYetStartingJourney,"
        end
        if isFinished?
          s += "Finished,"
        end
        if isTimeless?
          s += "Timeless,"
        end
        s += "vid=#{vid}, wvid=#{workingVid}, st=#{getStartTime}, et=#{getEndTime}"
      end
      s
    end

    def pushCurrentLocation(loc)
      gp = Integration::GeoPoint.new((loc.lat * 1E6).to_i, (loc.lon * 1E6).to_i)
      lastLocation = lastKnownLocation
      self.lastKnownLocation = gp
      self.lastKnownTimediff = loc.timediff
      self.lastKnownDirection = loc.dir
      self.lastKnownDistance = loc.distance
      self.lastKnownTime = loc.reported_time.to_s
      self.onRoute = loc.onroute
      self.reported = loc.reported
      [lastLocation, lastKnownLocation]
    end
  end
end