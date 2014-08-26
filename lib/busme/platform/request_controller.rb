module Platform
  class RequestController
    include RequestConstants

    # Called from the UI Thread.
    def onRequestState(requestState)
      case requestState.state
        when S_START
                          onStart(requestState)

        when S_INQUIRE_START
                          onInquireStart(requestState)
        when S_INQUIRE_IN_PROGRESS
        when S_INQUIRE_FINISH

        when S_ANSWER_START
                          onAnswerStart(requestState)
        when S_ANSWER_IN_PROGRESS
        when S_ANSWER_FINISH

        when S_REQUEST_START
                          onRequestStart(requestState)
        when S_REQUEST_IN_PROGRESS
        when S_REQUEST_FINISH

        when S_RESPONSE_START
                          onResponseStart(requestState)
        when S_RESPONSE_IN_PROGRESS
        when S_RESPONSE_FINISH

        when S_NOTIFY_START
                          onNotifyStart(requestState)
        when S_NOTIFY_IN_PROGRESS
        when S_NOTIFY_FINISH

        when S_ACK_START
                          onAckStart(requestState)
        when S_ACK_IN_PROGRESS
        when S_ACK_FINISH

        when S_FINISH
                          onFinish(requestState)
      end
    end

    def onStart(requestState)

    end

    def onInquireStart(requestState)

    end

    def onAnswerStart(requestState)

    end

    def onRequestStart(requestState)

    end

    def onResponseStart(requestState)

    end

    def onNotifyStart(requestState)

    end

    def onActStart(requestState)

    end

    def onFinish(requestState)

    end

  end
end