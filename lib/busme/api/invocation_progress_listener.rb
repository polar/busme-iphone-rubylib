module Api
  module UpdateProgressConstants
    U_START = 1
    U_ARG_START = 2
    U_ARG_FIN = 3
    U_REQ_START = 4
    U_REQ_IOERROR = 5
    U_REQ_FIN = 6
    U_RESP_START = 7
    U_RESP_FIN = 8
    U_FINISH = 9
  end
  module InvocationProgressListener
    include UpdateProgressConstants
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
