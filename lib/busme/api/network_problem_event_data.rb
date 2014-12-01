module Api
  class NetworkProblemEventData
    attr_accessor :reason
    attr_accessor :login

    def initialize(reason, login = nil)
      self.reason = reason
      self.login = login
    end
  end
end