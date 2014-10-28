module Api
  class Route
    include Encoding
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
    
    def propList
      # We do not save the busApi or journeyStore
      %w(
    @name
    @type
    @id
    @code
    @direction
    @vid
    @workingVid
    @timeless
    @sort
    @version
    @nw_lon
    @nw_lat
    @se_lon
    @se_lat
    @locationRefreshRate
    @startOffset
    @duration
    @startTime
    @endTime
    @schedStartTime
    @actualStartTime
    @patternid
    @patternids
    @lastKnownLocation
    @lastKnownTime
    @lastKnownTimediff
    @lastKnownDistance
    @lastKnownDirection
    @onRoute
    @timeZone
    @reported
      )
    end

    def initWithCoder1(decoder)
      self.busAPI = decoder[:busAPI]
      self.name = decoder[:name]
      self.type = decoder[:type]
      self.id = decoder[:id]
      self.code = decoder[:code]
      self.direction = decoder[:direction]
      self.vid = decoder[:vid]
      self.workingVid = decoder[:workingVid]
      self.timeless = decoder[:timeless]
      self.sort = decoder[:sort]
      self.version = decoder[:version]
      self.nw_lon = decoder[:nw_lon]
      self.nw_lat = decoder[:nw_lat]
      self.se_lon = decoder[:se_lon]
      self.se_lat = decoder[:se_lat]
      self.locationRefreshRate = decoder[:locationRefreshRate]
      self.startOffset = decoder[:startOffset]
      self.duration = decoder[:duration]
      self.startTime = decoder[:startTime]
      self.endTime = decoder[:endTime]
      self.schedStartTime = decoder[:schedStartTime]
      self.actualStartTime = decoder[:actualStartTime]
      self.patternid = decoder[:patternid]
      self.patternids = decoder[:patternids]
      self.lastKnownLocation = decoder[:lastKnownLocation]
      self.lastKnownTime = decoder[:lastKnownTime]
      self.lastKnownTimediff = decoder[:lastKnownTimediff]
      self.lastKnownDistance = decoder[:lastKnownDistance]
      self.lastKnownDirection = decoder[:lastKnownDirection]
      self.onRoute = decoder[:onRoute]
      self.timeZone = decoder[:timeZone]
      self.reported = decoder[:reported]
      self.journeyStore = decoder[:journeyStore]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def encodeWitHCoder1(encoder)
      encoder[:busAPI] = busAPI
      encoder[:name] = name
      encoder[:type] = type
      encoder[:id] = id
      encoder[:code] = code
      encoder[:direction] = direction
      encoder[:vid] = vid
      encoder[:workingVid] = workingVid
      encoder[:timeless] = timeless
      encoder[:sort] = sort
      encoder[:version] = version
      encoder[:nw_lon] = nw_lon
      encoder[:nw_lat] = nw_lat
      encoder[:se_lon] = se_lon
      encoder[:se_lat] = se_lat
      encoder[:locationRefreshRate] = locationRefreshRate
      encoder[:startOffset] = startOffset
      encoder[:duration] = duration
      encoder[:startTime] = startTime
      encoder[:endTime] = endTime
      encoder[:schedStartTime] = schedStartTime
      encoder[:actualStartTime] = actualStartTime
      encoder[:patternid] = patternid
      encoder[:patternids] = patternids
      encoder[:lastKnownLocation] = lastKnownLocation
      encoder[:lastKnownTime] = lastKnownTime
      encoder[:lastKnownTimediff] = lastKnownTimediff
      encoder[:lastKnownDistance] = lastKnownDistance
      encoder[:lastKnownDirection] = lastKnownDirection
      encoder[:onRoute] = onRoute
      encoder[:timeZone] = timeZone
      encoder[:reported] = reported
      encoder[:journeyStore] = journeyStore
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def preSerialize(api)
      # We no longer use YAML so we don't serialize these properties.
      # Doing this was interfering with iPhone concurrent access.
      # giving nil pointer errors accessing journeyStore.
      #self.busAPI = nil
      #self.journeyStore = nil
      #@paths = nil
      #@projectedPaths = nil
    end

    def postSerialize(api)
      self.busAPI = api
    end

    def getJourneyPattern(id)
      journeyStore.getPattern(id)
    end

    def journeyPatterns
      pids = (patternids ||[]) + (patternid ? [patternid] : [])
      pats = pids.map {|id| journeyStore.getPattern(id) }.compact
      pats
    end

    def initialize
      self.version = -1
      self.locationRefreshRate = 10 # seconds
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
      @projectedPaths ||= journeyPatterns.map {|x| x.projectedPath}
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
      threshold = busAPI.activeStartDisplayThreshold if threshold.nil? && busAPI
      time = Time.now if time.nil?
    end

    def isNotYetStartingJourney?
      if isJourney? && busAPI
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
      if loc
        distance = lastKnownDistance
        path_distance = getJourneyPattern(patternid).distance
        dist_from_last = getJourneyPattern(patternid).endPoint.distanceTo(loc)
        path_distance - distance < 10 && dist_from_last < 3 # feet
      end
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
      if busAPI.nil?
        if isRouteDefinition?
          s = "Route(#{code}, #{name}, pc=#{paths.size}, id=#{id}"
        end
        if isJourney?
          s = "Journey(#{code}, #{name}, id=#{id}, ver=#{version}, patid=#{patternid}"
        end
        return s
      end
      if isRouteDefinition?
        s = "Route(#{code}, #{name}, pc=#{paths.size}, id=#{id}"
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