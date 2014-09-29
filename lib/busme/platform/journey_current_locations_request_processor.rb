module Platform
  class JourneyCurrentLocationsRequestProcessor
    include Api::ArgumentPreparer
    include Api::ResponseProcessor

    attr_accessor :journeyBasketController

    def initialize(controller)
      self.journeyBasketController = controller
    end

    def getArguments
      params = []
      if journeyBasketController
        displays = journeyBasketController.getJourneyDisplays.select {|x| x.route.isJourney? && x.isPathVisible? }
        displays.each do |jd|
          params << ["journey_ids[]", jd.route.id]
        end
      end
      params
    end

    def onResponse(response)
      locationMap = {}
      if response && response.childNodes
        for tag in response.childNodes do
          if "jps" == tag.name.downcase
            for tag1 in tag.childNodes do
              if "jp" == tag1.name.downcase
                loc = Api::JourneyLocation.new
                loc.loadParsedXMLTag(tag1)
                locationMap[loc.id] = loc
              end
            end
          end
        end
      end
      pushCurrentLocations(locationMap)
    end

    protected

    def pushCurrentLocations(locationMap)
      if journeyBasketController && journeyBasketController.journeyBasket
        for id, loc in locationMap do
          journey = journeyBasketController.journeyBasket.getRoute(id)
          if journey
            locations = journey.pushCurrentLocation(loc)
            if (locations[0] != locations[1] ||
                  locations[0] && locations[0] != locations[1] ||
                  locations[1] && locations[1] != locations[0])
              journeyBasketController.onLocationUpdate(journey, locations)
            end
          end
        end
      end
    end
  end
end