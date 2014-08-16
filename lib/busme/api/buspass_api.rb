module Api
  class BuspassAPI < APIBase
    attr_accessor :apiURL
    attr_accessor :appVersion
    attr_accessor :platformName
    attr_accessor :buspass
    attr_accessor :ready
    attr_accessor :syncRate
    attr_accessor :updateRate
    attr_accessor :activeStartDisplayThreshold
    attr_accessor :busmeAppVersionString
    attr_accessor :loginManager
    attr_accessor :uiEvents
    attr_accessor :bgEvents

    def initialize(initialURL, platform, appVersion)
      super()
      self.apiURL = initialURL
      self.appVersion = appVersion
      self.platformName = platform

      self.buspass = Buspass.new
      self.ready = false
      self.activeStartDisplayThreshold = 10 * 60 # minutes
      self.busmeAppVersionString = "#{self.platformName} #{self.appVersion}"
      self.uiEvents = BuspassEventDistributor.new()
      self.bgEvents = BuspassEventDistributor.new()
      self.loginManager = LoginManager.new(self)
    end

    def isReady?
      ready
    end

    def getPlatformArgs()
      "platform=#{platformName}&app_version=#{appVersion}"
    end

    def getTrackingArgs()
      nil
    end

    def get()
      if isReady?
        buspass
      end
      forceGet()
    end

    def forceGet()
      url = "#{apiURL}?#{getPlatformArgs()}"
      ent = openURL(url)
      api = xmlParse(ent)
      if api && "API" == api.name
        if "1" == api.attributes["majorVersion"]
          self.buspass = bp = Buspass.new
          bp.mode = api.attributes["mode"]
          bp.name = api.attributes["name"]
          bp.slug = api.attributes["slug"]
          bp.authUrl = api.attributes["auth"]
          bp.loginUrl = api.attributes["login"]
          bp.registerUrl = api.attributes["register"]
          bp.logoutUrl = api.attributes["logout"]
          bp.oauthLoginUrl = api.attributes["oauth_login"]
          bp.oauthLogoutUrl = api.attributes["oauth_logout"]
          bp.postloc_time_rate = api.attributes["postloc_time_rate"]
          bp.postloc_dist_rate = api.attributes["postloc_dist_rate"]
          bp.curloc_time_rate = api.attributes["curloc_time_rate"]
          bp.lon = api.attributes["lon"]
          bp.lat = api.attributes["lat"]
          bp.box = api.attributes["box"]
          bp.timezone = api.attributes["timezone"]
          bp.time = api.attributes["time"]
          bp.timeoffset = api.attributes["timeoffset"]
          bp.datefmt = api.attributes["datefmt"]
          bp.getRouteJourneyIdsUrl = api.attributes["getRouteJourneyIds"]
          bp.getRouteDefinitionUrl = api.attributes["getRouteDefinition"]
          bp.getJourneyLocationUrl = api.attributes["getJourneyLocation"]
          bp.getMultipleJourneyLocationsUrl = api.attributes["getMultipleJourneyLocations"]
          bp.postJourneyLocationUrl = api.attributes["postJourneyLocation"]
          bp.getMessageUrl = api.attributes["getMessage"]
          bp.getMessagesUrl = api.attributes["getMessages"]
          bp.getMarkersUrl = api.attributes["getMarkers"]
          bp.postFeedbackUrl = api.attributes["postFeedback"]
          bp.updateUrl = api.attributes["update"]
          bp.updateRate = api.attributes["updateRate"]
          bp.activeStartDisplayThreshold = api.attributes["activeStartThreshold"]
          bp.activeEndWaitThreshold = api.attributes["activeEndWaitThreshold"]
          bp.offRouteDistanceThreshold = api.attributes["offRouteDistanceThreshold"]
          bp.offRouteCountThreshold = api.attributes["offRouteCountThreshold"]
          bp.offRouteTimeThreshold = api.attributes["offRouteTimeThreshold"]
          bp.getRouteJourneyIds1Url = api.attributes["getRouteJourneyIds1"]
          bp.markerClickThru = api.attributes["markerClickThru"]
          bp.messageClickThru = api.attributes["messageClickThru"]
          bp.syncRate = api.attributes["syncRate"]
          bp.bannerRefreshRate = api.attributes["bannerRefreshRate"]
          bp.bannerMaxImageSize = api.attributes["bannerMaxImageSize"]
          bp.bannerClickThru = api.attributes["bannerClickThru"]
          bp.helpUrl = api.attributes["helpUrl"]
          bp.bannerImageUrl = api.attributes["bannerImage"]
          if api.childNodes
            for message in api.childNodes do
              if "Message" == message.name
                msg = MasterMessage.new
                msg.loadParsedXML(message)
                bp.initialMessages << msg
              end
            end
          end
          self.syncRate = -1
          self.updateRate = -1
          self.ready = true
        end
      end
    end

    def passwordRegistration(login)
      login.url = buspass.registerUrl
      params = []
      params << ["email", login.email]
      params << ["password", login.password]
      params << ["password_confirmation", login.password]
      params << ["role_intent", login.roleIntent]
      params << ["auth_code", login.driverAuthCode]
      params << ["app_version", busmeAppVersionString()]
      resp = postURLResponse(buspass.registerUrl, params)
      status = resp.getStatusLine().statusCode
      entity = resp.getEntity()

      if status == 200
        tag = xmlParse(entity)
        if "login" == tag.name.downcase
          login.status = tag.attributes["status"]
          if "OK" == login.status
            login.name = tag.attributes["name"]
            email = tag.attributes['email']
            if email
              login.email = email
            end
            roleIntent = tag.attributes["roleIntent"]
            if roleIntent
              login.roleIntent = roleIntent
            end
            rolesLiteral = tag.attributes["roles"]
            if rolesLiteral
              login.roles = rolesLiteral.split(",")
              login.rolesLiteral = rolesLiteral
            end
            login.authToken = tag.attributes["authToken"]
            login.loginState = Login::LS_REGISTER_SUCCESS
          else
            login.loginState = Login::LS_REGISTER_FAILURE
          end
        else
          login.status = "NotProperResponse"
          login.loginState = Login::LS_REGISTER_FAILURE
        end
      else
        login.status = resp.getStatusLine().reason
        login.loginState = Login::LS_REGISTER_FAILURE
      end
      login
    end

    def passwordLogin(login)
      login.url = buspass.loginUrl
      params = []
      params << ["email", login.email]
      params << ["password", login.password]
      params << ["role_intent", login.roleIntent]
      params << ["auth_code", login.driverAuthCode]
      params << ["app_version", busmeAppVersionString]
      resp = postURLResponse(buspass.loginUrl, params)
      status = resp.getStatusLine().statusCode
      entity = resp.getEntity()

      if status == 200
        tag = xmlParse(entity)
        if "login" == tag.name.downcase
          login.status = tag.attributes["status"]
          if "OK" == login.status
            login.name = tag.attributes["name"]
            email = tag.attributes['email']
            if email
              login.email = email
            end
            roleIntent = tag.attributes["roleIntent"]
            if roleIntent
              login.roleIntent = roleIntent
            end
            rolesLiteral = tag.attributes["roles"]
            if rolesLiteral
              login.roles = rolesLiteral.split(",")
              login.rolesLiteral = rolesLiteral
            end
            login.authToken = tag.attributes["authToken"]
            login.loginState = Login::LS_LOGIN_SUCCESS
          else
            login.loginState = Login::LS_LOGIN_FAILURE
          end
        else
          login.status = "NotProperResponse"
          login.loginState = Login::LS_LOGIN_FAILURE
        end
      else
        login.status = resp.getStatusLine().reason
        login.loginState = Login::LS_LOGIN_FAILURE
      end
      login
    end

    def authTokenLogin(login)
      login.url = buspass.authUrl
      params = []
      params << ["access_token", login.authToken]
      params << ["role_intent", login.roleIntent]
      params << ["app_version", busmeAppVersionString()]
      resp = postURLResponse(buspass.authUrl, params)
      status = resp.getStatusLine().statusCode
      entity = resp.getEntity()

      if status == 200
        tag = xmlParse(entity)
        if "login" == tag.name.downcase
          login.status = tag.attributes["status"]
          if "OK" == login.status
            login.name = tag.attributes["name"]
            email = tag.attributes['email']
            if email
              login.email = email
            end
            roleIntent = tag.attributes["roleIntent"]
            if roleIntent
              login.roleIntent = roleIntent
            end
            rolesLiteral = tag.attributes["roles"]
            if rolesLiteral
              login.roles = rolesLiteral.split(",")
              login.rolesLiteral = rolesLiteral
            end
            login.authToken = tag.attributes["authToken"]
            login.name = tag.attributes["name"]
            login.loginState = Login::LS_AUTHTOKEN_SUCCESS
          else
            login.loginState = Login::LS_AUTHTOKEN_FAILURE
          end

        else
          login.status = "NotProperResponse"
          login.loginState = Login::LS_AUTHTOKEN_FAILURE
        end
      else
        login.status = resp.getStatusLine().reason
        login.loginState = Login::LS_AUTHTOKEN_FAILURE
      end
      login
    end

    def getBannerClickThru(id)
      if isReady?
        url = buspass.bannerClickThru
        if url
          url += getPlatformArgs
          args = getTrackingArgs
          url = args ? url : "#{url}&#{args}"
          params = []
          params << ["banner_id", id]
          params << ["master_slug", buspass.slug]

          entity = postURL(url, params)
          if entity
            tag = xmlParse(entity)
            if tag
              if "a" == tag.name.downcase
                tag.attributes["href"]
              end
            end
          end
        end
      end
    end

    def getMasterMessageClickThru(id)
      if isReady?
        url = buspass.messageClickThru
        if url
          url += getPlatformArgs
          args = getTrackingArgs
          url = args ? url : "#{url}&#{args}"
          params = []
          params << ["message_id", id]
          params << ["master_slug", buspass.slug]

          entity = postURL(url, params)
          if entity
            tag = xmlParse(entity)
            if tag
              if "a" == tag.name.downcase
                tag.attributes["href"]
              end
            end
          end
        end
      end
    end

    def getMarkerClickThru(id)
      if isReady?
        url = buspass.markerClickThru
        if url
          url += getPlatformArgs
          args = getTrackingArgs
          url = args ? url : "#{url}&#{args}"
          params = []
          params << ["message_id", id]
          params << ["master_slug", buspass.slug]

          entity = postURL(url, params)
          if entity
            tag = xmlParse(entity)
            if tag
              if "a" == tag.name.downcase
                tag.attributes["href"]
              end
            end
          end
        end
      end
    end

  end
end