module Api
  class RemoteInvocation
    attr_accessor :api
    attr_accessor :requestUrl
    attr_accessor :argumentPreparers
    attr_accessor :responseProcessors

    def initialize(api, requestURL)
      self.api = api
      self.requestUrl = requestURL
      self.argumentPreparers = []
      self.responseProcessors = []
    end

    def addArgumentPreparer(preparer)
      if preparer.is_a? Api::ArgumentPreparer
        self.argumentPreparers << preparer
      else
        raise "Bad Argument Preparer"
      end
    end

    def addResponseProcessor(processor)
      if processor.is_a? Api::ResponseProcessor
        self.responseProcessors << processor
      else
        raise "Bad ResponseProcessor"
      end
    end

    def invoke(progress = nil, isForced = false)
      progress.onUpdateStart(Time.now, isForced) if progress
      makeRequest = false
      if requestUrl
        progress.onArgumentsStart if progress
        parameters = []
        for preparer in argumentPreparers do
          args = preparer.getArguments
          if args
            parameters += args
            makeRequest = true
          end
        end
        progress.onArgumentsFinish(makeRequest) if progress
        response = nil
        if makeRequest
          progress.onRequestStart(Time.now) if progress
          begin
            response = makeRequestAndParseResponse(requestUrl, parameters)
          rescue IOError => boom
            progress.onRequestIOError(boom) if progress
          end
          progress.onRequestFinish(Time.now) if progress
          progress.onResponseStart if progress
          if response
            if handleResponse(response)
              for rp in responseProcessors do
                rp.onResponse(response)
              end
            end
          end
          progress.onResponseFinish if progress
        end
      end
      progress.onUpdateFinish(makeRequest, Time.now) if progress
    end

    # Place to handle any response attributes, or make sure you've got the right
    # tag.
    def handleResponse(response)
      true
    end

    protected

    def makeRequestAndParseResponse(requestURL, parameters)
      resp = api.postURLResponse(requestURL, parameters)
      tag = nil
      if resp
        status = resp.getStatusLine().statusCode
        entity = resp.getEntity()
        tag = nil
        if status == 200
          tag = api.xmlParse(entity)
        end
      end
      tag
    end
  end

end