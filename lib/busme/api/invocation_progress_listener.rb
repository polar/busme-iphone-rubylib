module Api
  module InvocationProgressListener
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
end
