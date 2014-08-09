module Platform
  class LoginManager
    attr_accessor :currentLogin
    attr_accessor :currentAuthToken

    def isLoggedIn?
      !!currentLogin
    end

    def getLogin
      currentLogin
    end

    def forgetLogin
      self.currentLogin = nil
      self.currentAuthToken = nil
    end


  end
end