module Api
  class Login
    attr_accessor :status
    attr_accessor :reason
    attr_accessor :name
    attr_accessor :email
    attr_accessor :driverAuthCode
    attr_accessor :roleIntent
    attr_accessor :rolesLiteral
    attr_accessor :roles
    attr_accessor :authToken

    def initialize(status, reason = "")
      self.status = status
      self.reason = reason
    end

    def hasRole?(name)
      roles.include?(name)
    end
  end
end