module Api
  class LoginManager
    include BuspassEventListener
    attr_accessor :api
    attr_accessor :login
    attr_accessor :authToken
    attr_accessor :roleIntent
    attr_accessor :email

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("LoginEvent", self)
      api.uiEvents.registerForEvent("LoginEvent", self)
    end

    def onBuspassEvent(event)
      if login != event.eventData
        self.login = event.eventData
      end
      process
    end

    def process
      case login.loginState
        # BG Events
        when Login::LS_AUTHTOKEN
          authTokenLogin
        when Login::LS_LOGIN
          passwordLogin
        when Login::LS_REGISTER
          registerLogin
        when Login::LS_LOGGED_IN
        when Login::LS_LOGGED_OUT

        # Check UI Events
        else
          confirmLogin
      end
    end

    def authTokenLogin
      login.loginState = Login::LS_AUTHTOKEN
      login.authToken = authToken
      login.roleIntent = roleIntent
      api.authTokenLogin(login)
    rescue Exception => boom
      login.status = "BadResponse"
      login.loginState = Login::LS_AUTHTOKEN_FAILURE
    ensure
      api.uiEvents.postEvent("LoginEvent", login)
    end

    def registerLogin
      login.loginState = Login::LS_REGISTER
      login.email = email
      login.roleIntent = roleIntent
      api.passwordRegistration(login)
    rescue Exception => boom
      login.status = "BadResponse"
      login.loginState = Login::LS_REGISTER_FAILURE
    ensure
      api.uiEvents.postEvent("LoginEvent", login)
    end

    def passwordLogin
      login.loginState = Login::LS_LOGIN
      login.email = email
      login.roleIntent = roleIntent
      api.passwordLogin(login)
    rescue Exception => boom
      login.status = "BadResponse"
      login.loginState = Login::LS_LOGIN_FAILURE
    ensure
      api.uiEvents.postEvent("LoginEvent", login)
    end

    def confirmLogin
      case login.loginState
        when Login::LS_LOGIN_SUCCESS,Login::LS_LOGIN_FAILURE
          confirmPasswordLogin
        when Login::LS_REGISTER_SUCCESS, Login::LS_REGISTER_FAILURE
          confirmRegisterLogin
        when Login::LS_AUTHTOKEN_SUCCESS, Login::LS_AUTHTOKEN_FAILURE
          confirmAuthTokenLogin
        else
          raise "Bad Option"
      end
    end

    def confirmPasswordLogin
      case login.loginState
        when Login::LS_LOGIN_SUCCESS
          login.loginState = Login::LS_LOGGED_IN
        when Login::LS_LOGIN_FAILURE
          case login.status
            when "InvalidPassword"
              login.loginState = Login::LS_LOGIN
            when "NotAuthorized"
              login.loginState = Login::LS_LOGIN
            when "NotRegistered"
              login.loginState = Login::LS_REGISTER
            when "InvalidToken"
              login.loginState = Login::LS_LOGIN
          end
      end
      api.bgEvents.postEvent("LoginEvent", login)
    end

    def confirmRegisterLogin
      case login.loginState
        when Login::LS_REGISTER_SUCCESS
          login.loginState = Login::LS_LOGGED_IN
        when Login::LS_REGISTER_FAILURE
          case login.status
            when "InvalidPassword"
              login.loginState = Login::LS_LOGIN
            when "NotAuthorized"
              login.loginState = Login::LS_LOGIN
            when "NotRegistered"
              login.loginState = Login::LS_REGISTER
            when "InvalidToken"
              login.loginState = Login::LS_LOGIN
          end
      end
      api.bgEvents.postEvent("LoginEvent", login)
    end

    def confirmAuthTokenLogin
      case login.loginState
        when Login::LS_AUTHTOKEN_SUCCESS
          login.loginState = Login::LS_LOGGED_IN
        when Login::LS_AUTHTOKEN_FAILURE
          if login.quiet
            login.loginState = Login::LS_LOGGED_OUT
          else
            login.loginState = Login::LS_LOGIN
          end
      end
      api.bgEvents.postEvent("LoginEvent", login)
    end

    def performLogout
      api.forgetLogin
    rescue Exception => boom
    ensure
      login.loginState = Login::LS_LOGGED_OUT
      api.uiEvents.postEvent("LoginEvent", login)
    end
  end
end