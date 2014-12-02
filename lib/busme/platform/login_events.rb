module Platform

  class LoginEventData
    attr_accessor :loginManager
    attr_accessor :loginForeground
    attr_accessor :loginBackground

    def initialize(manager)
      self.loginManager = manager
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
            when Api::Login::LS_AUTHTOKEN_FAILURE,
                Api::Login::LS_REGISTER_FAILURE,
                Api::Login::LS_LOGIN_FAILURE
              presentError(eventData)
            when
              Api::Login::LS_AUTHTOKEN_SUCCESS,
              Api::Login::LS_REGISTER_SUCCESS,
              Api::Login::LS_LOGIN_SUCCESS
              presentConfirmation(eventData)
          end
      end
    end

    def passwordLogin(eventData)
      login = eventData.loginManager.login
      if !login.quiet
        presentPasswordLogin(eventData)
      end
    end

    def registerLogin(eventData)
      login = eventData.loginManager.login
      if !login.quiet
        presentRegisterLogin(eventData)
      end
    end

    def processError(eventData)
      login = eventData.loginManager.login
      if !login.quiet
        presentError(eventData)
      else
        onContinue(eventData)
      end
    end

    def processSuccess(eventData)
      login = eventData.loginManager.login
      if !login.quiet
        presentConfirmation(eventData)
      else
        onContinue(eventData)
      end
    end

    def dismiss(eventData = nil)
    end

    def presentPasswordLogin(eventData)
      # Collect UserName and Password
      # Possible Driver Auth Code
      onSubmit(eventData)
    end

    def presentRegisterLogin(eventData)
      # Get Username and Password
      # Possible Drive AuthCode
      onSubmit(eventData)
    end

    def presentError(eventData)
      onContinue(eventData)
    end

    def presentConfirmation(eventData)
      onContinue(eventData)
    end

    def onSubmit(eventData)
      dismiss(eventData)
      api.bgEvents.postEvent("LoginEvent", eventData)
    end

    def onContinue(eventData)
      dismiss(eventData)
      eventData.loginManager.exitProtocol
      api.uiEvents.postEvent("LoginEvent", eventData)
      # case eventData.loginManager.login.loginState
      #   when Api::Login::LS_LOGGED_IN, Api::Login::LS_LOGGED_OUT
      #   else
      #     api.uiEvents.postEvent("LoginEvent", eventData)
      # end
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
      api.uiEvents.postEvent("LoginEvent", eventData)
    end
  end
end