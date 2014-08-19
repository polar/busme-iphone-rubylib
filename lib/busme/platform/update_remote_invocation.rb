module Platform

  class UpdateEventData
    attr_accessor :pleaseStop
    attr_accessor :progressListener
    attr_accessor :isForced
  end

  class UpdateRemoteInvocation < Api::RemoteInvocation
    include Api::BuspassEventListener
    attr_accessor :enabled

    def initialize(guts)
      super(guts.api, nil)
      banners = BannerRequestProcessor.new(guts.bannerBasket)
      markers = MarkerRequestProcessor.new(guts.markerBasket)
      messages = MasterMessageRequestProcessor.new(guts.masterMessageBasket)
      locations = JourneyCurrentLocationsRequestProcessor.new(guts.journeyDisplayController)

      addArgumentPreparer(banners)
      addArgumentPreparer(markers)
      addArgumentPreparer(messages)
      addArgumentPreparer(locations)

      addResponseProcessor(banners)
      addResponseProcessor(markers)
      addResponseProcessor(messages)
      addResponseProcessor(locations)
      api.bgEvents.registerForEvent("Update", self)
    end

    def requestUrl
      if api.isReady?
        api.buspass.updateUrl
      end
    end

    # Returns true if we have a response tag, then response processors will be invoked.
    def handleResponse(tag)
      if "response" == tag.name.downcase
        updateRate = tag.attributes["updateRate"]
        syncRate = tag.attributes["syncRate"]
        api.updateRate = updateRate.to_i if updateRate
        api.syncRate = syncRate.to_i if syncRate
        true
      else
        false
      end
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.pleaseStop
        self.enabled = false
        return
      end
      if enabled
        invoke(eventData.progressListener, eventData.isForced)
      end
    end
  end
end