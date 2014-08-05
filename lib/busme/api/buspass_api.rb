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

    def initialize(initialURL, platform, appVersion)
      super()
      self.apiURL = initialURL
      self.appVersion = appVersion
      self.platformName = platform

      self.buspass = Buspass.new
      self.ready = false
      self.activeStartDisplayThreshold = 10 * 60 # minutes
    end

    def isReady
      ready
    end

    def getPlatformArgs()
      "platform=#{platformName}&app_version=#{appVersion}"
    end

    def get()
      if isReady
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

  end
end