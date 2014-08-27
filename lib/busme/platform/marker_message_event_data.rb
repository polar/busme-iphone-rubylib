module Platform
  class MarkerMessageEventData < RequestState
    include MarkerMessageConstants
    attr_accessor :marker_info
    attr_accessor :thruUrl
    attr_accessor :resolve
    attr_accessor :error

    def initialize(marker_info)
      self.marker_info = marker_info
      self.state       = S_START
    end

    def dup
      evd = MarkerMessageEventData.new(marker_info)
      evd.thruUrl = thruUrl
      evd.resolve = resolve
      evd.error = error
      evd
    end
  end
end
