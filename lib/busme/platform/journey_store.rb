module Platform
  class JourneyStore
    attr_accessor :journeys
    attr_accessor :patterns

    def initialize
      self.journeys = {}
      self.patterns = {}
    end

    def getPattern(id)
      patterns[id]
    end

    def storePattern(pattern)
      patterns[pattern.id] = pattern
    end

    def storeJourney(route)
      route.journeyStore = self
      journeys[route.id] = route
    end

    def getJourney(id)
      journeys[id]
    end

    def preSerialize
      journeys.values.each {|x| x.preSerialize}
    end

    def postSerialize(api)
      journeys.values.each {|x| x.postSerialize(api); x.journeyStore = self}
    end
  end
end