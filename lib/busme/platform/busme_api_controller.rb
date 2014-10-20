
module Platform
  class BusmeApiSetEventData < Struct.new(:uiData, :api, :directory)

  end
  class BusmeApiGetEventData < Struct.new(:uiData, :get)

  end
  class BusmeApiController
    attr_accessor :guts
    def initialize(args)
      self.guts = args.delete :guts
      guts.api.bgEvents.registerForEvent("BusmeApi:set", self)
      guts.api.bgEvents.registerForEvent("BusmeApi:get", self)
    end

    def onBuspassEvent(event)
      case event.eventName
        when "BusmeApi:set"
          puts "Got Event #{event}"
          doSet(event.eventData)
        when "BusmeApi:get"
          doGet(event.eventData)
      end
    end

    def doSet(eventData)
      puts "BusmeApiController.doSet #{eventData.class.name}##{eventData.__id__}"
      api = eventData.api
      dir = eventData.directory
      guts.storeMasterApi
      oldapi = guts.api
      guts.reinitializeAPI(api: api, directory: dir)
      # Api has changed and so has the event distributors
      guts.api.bgEvents.registerForEvent("BusmeApi:set", self)
      guts.api.bgEvents.registerForEvent("BusmeApi:get", self)

      # We fire the onSet event on the old API, so that dependents
      # can reassign events if need be.
      if oldapi
        oldapi.uiEvents.postEvent("BusmeApi:preSet", eventData)
      end
      guts.api.uiEvents.postEvent("BusmeApi:onSet", eventData)
    end

    def doGet(eventData)
      puts "BusmeApiController.doGet"
      eventData.get = guts.getMasterApi
      guts.api.uiEvents.postEvent("BusmeApi:onGet", eventData)
    end
  end
end