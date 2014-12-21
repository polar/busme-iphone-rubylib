module Platform
  class BusmeConfigurator

    def getDefaultMaster
      @defaultMaster
    end

    def setDefaultMaster(master)
      @defaultMaster = master
    end

    def removeDefaultMaster
      @defaultMaster = nil
    end

    def getLastLocation
      PM.logger.info "#{self.class.name}:#{__method__} #{@location}"
      @lastLocation
    end

    def setLastLocation(gp)
      @lastLocation = gp
    end

    def retrieveStoredAuthTokenForMaster(name)

    end

    def forgetUserForMaster(masterName)

    end

    def storeCredentialsForMaster(master, login)

    end

    def removeCredentialsAuthTokenForMaster(master, login)

    end
  end
end