module Platform
  # These constants are for the state of the Foreground Request to Background Request to
  # Foreground notification and Acknowledgement
  # It defines a protocol of state changes downward that the RequestController should
  # be extended.


  class RequestState
    include RequestConstants
    attr_accessor :state

    def initialize
      self.state = S_START
    end
  end

end