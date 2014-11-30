module Api
  class LoginManager
    include BuspassEventListener
    attr_accessor :api
    attr_accessor :login
    attr_accessor :authToken
    attr_accessor :roleIntent
    attr_accessor :email

    def initialize(api, login = nil)
      self.api = api
      self.login = login
    end


    def enterProtocol(login = nil)
      self.login = login  if login
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
        else
          raise "Bad Option #{login.inspect}"
      end
    end

    def authTokenLogin
      login.authToken = authToken
      login.roleIntent = roleIntent
      api.authTokenLogin(login)
    rescue IOError => boom
      login.status = "NetworkProblem"
      login.loginState = Login::LS_AUTHTOKEN_FAILURE
    rescue Exception => boom
      login.status = "BadResponse"
      login.loginState = Login::LS_AUTHTOKEN_FAILURE
    end

    def registerLogin
      login.loginTries += 1
      if login.loginTries < Login::LS_TRY_LIMIT
        login.email ||= email
        login.roleIntent ||= roleIntent
        api.passwordRegistration(login)
      else
        login.loginState = Login::LS_REGISTER_FAILURE
        login.status = "Too many tries"
      end

    rescue IOError => boom
      login.status = "NetworkProblem"
      login.loginState = Login::LS_REGISTER_FAILURE
    rescue Exception => boom
      login.status = "BadResponse"
      login.loginState = Login::LS_REGISTER_FAILURE
    end

    def passwordLogin
      login.loginTries += 1
      if login.loginTries < Login::LS_TRY_LIMIT
        login.email ||= email
        login.roleIntent ||= roleIntent
        api.passwordLogin(login)
      else
        login.loginState = Login::LS_LOGIN_FAILURE
        login.status = "Too many tries"
      end
    rescue IOError => boom
      login.status = "NetworkProblem"
      login.loginState = Login::LS_LOGIN_FAILURE
    rescue Exception => boom
      login.status = "BadResponse"
      login.loginState = Login::LS_LOGIN_FAILURE
    end

    def exitProtocol
      case login.loginState
        when Login::LS_LOGIN_SUCCESS,Login::LS_LOGIN_FAILURE
          confirmPasswordLogin
        when Login::LS_REGISTER_SUCCESS, Login::LS_REGISTER_FAILURE
          confirmRegisterLogin
        when Login::LS_AUTHTOKEN_SUCCESS, Login::LS_AUTHTOKEN_FAILURE
          confirmAuthTokenLogin
        else
          raise "Bad Option #{login.inspect}"
      end
    end

    def confirmPasswordLogin
      case login.loginState
        when Login::LS_LOGIN_SUCCESS
          login.loginState = Login::LS_LOGGED_IN
        when Login::LS_LOGIN_FAILURE
          if login.quiet || login.loginTries >= Api::Login::LS_TRY_LIMIT
            login.loginState = Login::LS_LOGGED_OUT
          else
            case login.status
              when "NetworkProblem"
                login.loginState = Login::LS_LOGIN
              when "InvalidPassword"
                login.loginState = Login::LS_LOGIN
              when "NotAuthorized"
                login.loginState = Login::LS_LOGIN
              when "NotRegistered"
                login.loginState = Login::LS_REGISTER
                login.loginTries = 0
              when "InvalidToken"
                login.loginState = Login::LS_LOGIN
            end
          end
      end
    end

    def confirmRegisterLogin
      case login.loginState
        when Login::LS_REGISTER_SUCCESS
          login.loginState = Login::LS_LOGGED_IN
        when Login::LS_REGISTER_FAILURE
          if login.quiet || login.loginTries >= Api::Login::LS_TRY_LIMIT
            login.loginState = Login::LS_LOGGED_OUT
          else
            case login.status
              when "NetworkProblem"
                login.loginState = Login::LS_REGISTER
              when "InvalidPassword"
                login.loginState = Login::LS_REGISTER
              when "InvalidPasswordConfirmation"
                login.loginState = Login::LS_REGISTER
              when "NotAuthorized"
                login.loginState = Login::LS_REGISTER
              when "NotRegistered"
                login.loginState = Login::LS_REGISTER
              when "InvalidToken"
                login.loginState = Login::LS_REGISTER
            end
          end
      end
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
    end

    def performLogout
      api.forgetLogin
    rescue IOError => boom
      login.status = "NetworkProblem"
      login.loginState = Login::LS_LOGGED_OUT
    rescue Exception => boom
    ensure
      login.loginState = Login::LS_LOGGED_OUT
    end
  end
end