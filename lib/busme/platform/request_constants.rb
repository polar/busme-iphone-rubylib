module Platform
  module RequestConstants
    S_START                = 0
    S_INQUIRE_START        = 1
    S_INQUIRE_IN_PROGRESS  = 1.5
    S_INQUIRE_FINISH       = 1.7
    S_INQUIRE_ERROR        = 1.9

    S_ANSWER_START         = 2
    S_ANSWER_IN_PROGRESS   = 2.5
    S_ANSWER_FINISH        = 2.7
    S_ANSWER_ERROR         = 2.9

    S_REQUEST_START        = 3
    S_REQUEST_IN_PROGRESS  = 3.5
    S_REQUEST_FINISH       = 3.7
    S_REQUEST_ERROR        = 3.9

    S_RESPONSE_START       = 4
    S_RESPONSE_IN_PROGRESS = 4.5
    S_RESPONSE_FINISH      = 4.7
    S_RESPONSE_ERROR       = 4.9

    S_NOTIFY_START         = 5
    S_NOTIFY_IN_PROGRESS   = 5.5
    S_NOTIFY_FINISH        = 5.7
    S_NOTIFY_ERROR         = 5.9

    S_ACK_START            = 6
    S_ACK_IN_PROGRESS      = 6.5
    S_ACK_FINISH           = 6.7
    S_ACK_ERROR            = 6.9

    S_FINISH               = 9
  end
end