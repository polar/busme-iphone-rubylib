module Platform


  class UpdateRemoteInvocation < Api::RemoteInvocation

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
  end
end