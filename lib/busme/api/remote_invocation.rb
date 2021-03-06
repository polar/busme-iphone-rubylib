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
      progress.onUpdateStart(Utils::Time.current, isForced) if progress
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
          progress.onRequestStart(Utils::Time.current) if progress
          begin
            response = makeRequestAndParseResponse(requestUrl, parameters)
          rescue Api::HTTPError => boom
            progress.onRequestIOError(boom) if progress
          end
          progress.onRequestFinish(Utils::Time.current) if progress
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
      progress.onUpdateFinish(makeRequest, Utils::Time.current) if progress
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
          if tag.nil?
            status = Integration::Http::StatusLine.new(500, "Bad response from server")
            raise Api::HTTPError.new(status)
          end
        else
          raise Api::HTTPError.new(resp.getStatusLine)
        end
      else
        status = Integration::Http::StatusLine.new(500, "No response from server")
        raise Api::HTTPError.new(status)
      end
      tag
    end
  end

end