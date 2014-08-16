module Platform

  class LoginEventData
    attr_accessor :loginManager
    attr_accessor :loginTries
    attr_accessor :loginForeground
    attr_accessor :loginBackground

    def initialize(manager)
      self.loginManager = manager
      self.loginTries   = 0
    end
  end

  class LoginForeground
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.uiEvents.registerForEvent("LoginEvent", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      if eventData.is_a? LoginEventData
        eventData.loginForeground = self
        loginManager = eventData.loginManager
        login = loginManager.login
        case login.loginState
          when Api::Login::LS_LOGIN
            passwordLogin(eventData)
          when Api::Login::LS_REGISTER
            registerLogin(eventData)
          when Api::Login::LS_LOGGED_IN
            dismiss(eventData)
          when Api::Login::LS_LOGGED_OUT
            dismiss(eventData)
        end
      end
    end

    def passwordLogin(eventData)
      eventData.loginTries += 1
      if eventData.loginTries < 3
        presentPasswordLogin(eventData)
      else
        presentError(eventData)
      end
    end

    def registerLogin(eventData)
      eventData.loginTries += 1
      if eventData.loginTries < 3
        presentRegisterLogin(eventData)
      else
        presentError(eventData)
      end
    end

    def dismiss(eventData = nil)

    end

    def presentPasswordLogin(eventData)
      # Collect UserName and Password
      # Possible Driver Auth Code
    end

    def presentRegisterLogin(eventData)
      # Get Username and Password
      # Possible Drive AuthCode
    end

    def presentError(eventData)

    end

    def onSubmit(eventData)
      dismiss(eventData)
      api.bgEvents.postEvent("LoginEvent", eventData)
    end

    def onCancel(eventData)
      dismiss(eventData)
    end
  end

  class LoginBackground
    include Api::BuspassEventListener
    attr_accessor :api

    def initialize(api)
      self.api = api
      api.bgEvents.registerForEvent("LoginEvent", self)
    end

    def onBuspassEvent(event)
      eventData = event.eventData
      eventData.loginBackground = self
      loginManager = eventData.loginManager
      login = loginManager.login
      loginManager.enterProtocol(login)
      loginManager.exitProtocol
      case eventData.loginManager.login.loginState
        when Api::Login::LS_LOGGED_IN, Api::Login::LS_LOGGED_OUT
          api.uiEvents.postEvent("LoginEvent", eventData)
        when Api::Login::LS_LOGIN, Api::Login::LS_REGISTER
          if eventData.loginManager.login.status == "NetworkProblem"
            data = Platform::NetworkEventData.new
            data.reason = "login"
            data.login = eventData
            api.uiEvents.postEvent("NetworkProblem", data)
          else
            api.uiEvents.postEvent("LoginEvent", eventData)
          end
        else
          api.uiEvents.postEvent("LoginEvent", eventData)
      end
    end

  end
end