module Platform
  class JourneySyncInvocationProgressListener
    include Api::InvocationProgressListener
    attr_accessor :syncProgressListener
    def initialize(syncProgressListener)
      self.syncProgressListener = syncProgressListener
    end
    def onUpdateStart(time, isForced)
      syncProgressListener.onBegin(isForced)
    end
    def onRequestStart(time)
      syncProgressListener.onSyncStart
    end
    def onUpdateFinish(makeRequest, time)
      syncProgressListener.onDone
    end
  end
  class JourneySyncRemoteInvocation < Api::RemoteInvocation
    include Api::BuspassEventListener
    attr_accessor :processor
    attr_accessor :syncProgressListener
    attr_accessor :invocationProgressListener

    def initialize(api, journeyDisplayController, syncProgressListener)
      super(api, nil)
      self.processor = JourneySyncRequestProcessor.new(journeyDisplayController)
      self.syncProgressListener = processor.progressListener = syncProgressListener
      self.invocationProgressListener = JourneySyncInvocationProgressListener.new(syncProgressListener)

      addArgumentPreparer(processor)
      addResponseProcessor(processor)
    end

    def requestUrl
      if api.isReady?
        api.buspass.getRouteJourneyIds1Url
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

    def perform(isForced)
      invoke(invocationProgressListener, isForced)
    end
  end
end