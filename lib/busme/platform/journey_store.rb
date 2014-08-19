module Platform
  class JourneyStore < Api::JourneyStore
    attr_accessor :journeys
    attr_accessor :patterns

    def initialize
      self.journeys = {}
      self.patterns = {}
    end

    def getPattern(id)
      patterns[id]
    end

    def containsPattern?(id)
      patterns.keys.include?(id)
    end

    def containsJourney?(id)
      journeys.keys.include?(id)
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

    def removeJourney(id)
      journeys.delete id
    end

    def removePattern(id)
      patterns.delete id
    end

    def preSerialize(api)
      journeys.values.each {|x| x.preSerialize(api)}
    end

    def postSerialize(api)
      journeys.values.each {|x| x.postSerialize(api); x.journeyStore = self}
    end
  end
end