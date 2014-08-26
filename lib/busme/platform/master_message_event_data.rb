module Platform
  class MasterMessageEventData < RequestState
    include MasterMessageConstants
    attr_accessor :masterMessage
    attr_accessor :thruUrl
    attr_accessor :resolve
    attr_accessor :error

    def initialize(message)
      self.masterMessage = message
      self.state       = S_START
    end

    def dup
      evd = MasterMessageEventData.new(masterMessage)
      evd.thruUrl = thruUrl
      evd.resolve = resolve
      evd.error = error
      evd
    end
  end
end
