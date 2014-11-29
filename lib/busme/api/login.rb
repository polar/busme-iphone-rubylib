module Api
  class Login
    attr_accessor :status
    attr_accessor :reason
    attr_accessor :url
    attr_accessor :name
    attr_accessor :email
    attr_accessor :password
    attr_accessor :driverAuthCode
    attr_accessor :roleIntent
    attr_accessor :rolesLiteral
    attr_accessor :roles
    attr_accessor :authToken
    attr_accessor :loginState
    attr_accessor :loginTries
    attr_accessor :quiet

    LS_LOGIN = 1
    LS_LOGIN_FAILURE = 25
    LS_LOGIN_SUCCESS = 27
    LS_REGISTER = 5
    LS_REGISTER_SUCCESS = 55
    LS_REGISTER_FAILURE = 56
    LS_LOGGED_IN = 6
    LS_LOGGED_OUT = 7
    LS_AUTHTOKEN = 9
    LS_AUTHTOKEN_FAILURE = 10
    LS_AUTHTOKEN_SUCCESS =11

    LS_TRY_LIMIT = 3

    def initialize
      self.roles = []
      self.rolesLiteral = ""
      self.quiet = true
    end

    def hasRole?(name)
      roles.include?(name)
    end
  end
end