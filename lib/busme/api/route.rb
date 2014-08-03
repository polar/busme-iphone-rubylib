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
    attr_accessor :lastKnownDistance
    attr_accessor :onRoute

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

    end

    def getEndTime

    end

    def

  end
end