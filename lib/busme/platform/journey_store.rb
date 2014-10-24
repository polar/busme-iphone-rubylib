module Platform
  class JourneyStore < Api::JourneyStore
    attr_accessor :journeys
    attr_accessor :patterns

    def propList
      %w(@journeys @patterns)
    end

    def initWithCoder1(decoder)
      self.journeys = decoder[:journeys]
      self.patterns = decoder[:patterns]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def encodeWithCoder1(encoder)
      encoder[:journeys] = journeys
      encoder[:patterns] = patterns
    rescue Exception => boom
      puts "#{boom}"
    end

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

    def printContents
      puts "JourneyStore(#{journeys.values.size} Journeys, #{patterns.size} Patterns)"
      journeys.values.each do |x|
        puts "#{x}"
      end
      patterns.values.each do |x|
        puts "#{x}"
      end
    end
  end
end