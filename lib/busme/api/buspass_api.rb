module Api
  class BuspassAPI < APIBase
    attr_accessor :apiURL
    attr_accessor :master_slug
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
    attr_accessor :loginCredentials
    attr_accessor :startReporting
    attr_accessor :offRouteDistanceThreshold
    attr_accessor :offRouteCountThreshold
    attr_accessor :offRouteTimeThreshold

    def initialize(http_client, master_slug, initialURL, platform, appVersion)
      super(http_client)
      self.apiURL = initialURL
      self.master_slug = master_slug
      self.appVersion = appVersion
      self.platformName = platform

      self.buspass = Buspass.new
      self.ready = false
      self.activeStartDisplayThreshold = 10 * 60 * 1000 # 10 minutes
      self.busmeAppVersionString = "#{self.platformName} #{self.appVersion}"
      self.uiEvents = BuspassEventDistributor.new(name: "UIEvents:#{master_slug}")
      self.bgEvents = BuspassEventDistributor.new(name: "BGEvents:#{master_slug}")
      self.loginManager = LoginManager.new(self)
    end

    def isReady?
      ready
    end

    def loggedIn?
      loginCredentials && loginCredentials.loginState == Login::LS_LOGGED_IN ? loginCredentials : nil
    end

    def clearLogin
      self.loginCredentials = nil
    end

    def getPlatformArgs()
      "platform=#{platformName}&app_version=#{appVersion}"
    end

    attr_accessor :lastKnownLocation

    def getTrackingArgs()
      if lastKnownLocation
        "lat=#{lastKnownLocation.latitude}&lon=#{lastKnownLocation.longitude}"
      else
        ""
      end
    end

    def get()
      if isReady?
        buspass
      end
      forceGet()
    end

    def forceGet()
      url = "#{apiURL}?#{getPlatformArgs()}"
      resp = getURLResponse(url)
      status = resp.getStatusLine()
      if status.statusCode.to_i == 200
        ent = resp.getEntity()
        if ent
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
              self.syncRate =  bp.syncRate ? bp.syncRate.to_i : 10000
              self.updateRate = bp.updateRate ? bp.updateRate.to_i : 40000
              self.activeStartDisplayThreshold = bp.activeStartDisplayThreshold ? bp.activeStartDisplayThreshold.to_f : 10000
              self.offRouteDistanceThreshold = bp.offRouteDistanceThreshold ? bp.offRouteDistanceThreshold.to_f : 200
              self.offRouteCountThreshold = bp.offRouteCountThreshold ? bp.offRouteCountThreshold.to_i : 10
              self.offRouteTimeThreshold = bp.offRouteTimeThreshold ? bp.offRouteTimeThreshold.to_f : 20000
              self.ready = true
              self
            end
          else
            puts "Cannot get answer from #{url}"
            raise Api::HTTPError.new(Integration::Http::StatusLine.new(500, "Bad Response From Server"))
          end
        else
          raise Api::HTTPError.new(Integration::Http::StatusLine.new(590, "App Internal Error"))
        end
      else
        raise Api::HTTPError.new(status)
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

    class Query
      attr_accessor :query

      def initialize
        self.query = ""
      end

      def <<(args)
        if args && ! args.empty?
          if query.empty?
            self.query = args || ""
          else
            self.query += "&#{args}"
          end
        end
      end
      def to_s
        query.empty? ? "" : "?#{query}"
      end
    end

    def getDefaultQuery
      q = Query.new
      q << getPlatformArgs
      q << getTrackingArgs
      q
    end

    def getBannerClickThru(id)
      if isReady?
        url = buspass.bannerClickThru
        if url
          query = getDefaultQuery
          url += query.to_s
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
          query = getDefaultQuery
          url += query.to_s
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
          query = getDefaultQuery
          url += query.to_s
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

    # Returns nil, ok, notavailable, notloggedin
    def postJourneyLocation(route, location, role)
      if isReady?
        url = buspass.postJourneyLocationUrl
        if url
          params = []
          params << ["id", route.id]
          params << ["lat", location.latitude]
          params << ["lon", location.longitude]
          params << ["dir", location.bearing]
          params << ["reported_time", location.time]
          params << ["speed", location.speed]
          if "driver" == role
            params << ["driver", "1"]
          end

          entity = postURL(url, params)
          if entity
            tag = xmlParse(entity)
            if tag
              case tag.name.downcase
                when "ok"
                when "notavailable"
                when "notloggedin"
              end
              return tag.name.downcase
            end
          end
        end
      end
    end

    def getRouteDefinition(nameid)
      if isReady?
        url = buspass.getRouteDefinitionUrl
        if url
          query = getDefaultQuery
          query << "id=#{nameid.id}"
          query << "type=#{nameid.type}" if nameid.type
          url += query.to_s

          entity = openURL(url)
          if entity
            tag = xmlParse(entity)
            if tag
              route = Api::Route.new
              route = route.loadParsedXML(tag)
              if route
                return route
              else
                puts "getRouteDefinition(#{url}) definition was not valid."
              end
            else
              puts "getRouteDefinition(#{url}) did not parse"
            end
          end
        end
      end
    end

    def getJourneyPattern(id)
      if isReady?
        url = buspass.getRouteDefinitionUrl
        if url
          query = getDefaultQuery
          query << "id=#{id}"
          query << "type=P"
          url += query.to_s

          entity = openURL(url)
          if entity
            tag = xmlParse(entity)
            if tag
              pattern = Api::JourneyPattern.new
              pattern.loadParsedXML(tag)
              return pattern
            else
              puts "getJourneyPattern(#{url}) did not parse"
            end
          end
        end
      end
    end

  end
end