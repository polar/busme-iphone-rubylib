module Platform
  class RequestUpdater
    module UpdateProgressListener
      def onUpdateStart(time, isForced); end
      def onArgumentsStart(); end
      def onArgumentsFinish(makeRequest); end
      def onRequestStart(time); end
      def onRequestIOError(io_exception); end
      def onRequestFinish(time); end
      def onResponseStart(); end
      def onResponseFinish();end
      def onUpdateFinish(makeRequest, time);end
    end

    attr_accessor :requestUrl
    attr_accessor :argumentPreparers
    attr_accessor :responseProcessors

    def update(listener, isForced)
      listener.onUpdateStart(Time.now, isforced) if listener
      makeRequest = false
      if requestUrl
        listener.onArgumentsStart if listener
        parameters = []
        for preparer in argumentPreparers do
          args = preparer.getArguments
          if args
            parameters += args
            makeRequest = true
          end
        end
        listener.onArgumentsFinish(makeRequest)
        response = nil
        if makeRequest
          listener.onRequestStart(Time.now) if listener
          begin
            response = makeRequestAndGetResponse(requestUrl, parameters)
          rescue IOError => boom
            listener.onRequestIOError(boom) if listener
          end
          listener.onRequestFinish(Time.now) if listener
          listener.onResponseStart if listener
          if response
            for rp in responseProcessors do
              rp.processResponse(response)
            end
          end
          listener.onResponseFinish if listener
        end
      end
      listener.onUpdateFinish(makeRequest, Time.now)
    end
  end

  def makerRequestAndGetResponse(requestURL, parameters)
    raise "NotImplemented"
  end

end