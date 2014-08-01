module Api
  class Buspass
    attr_accessor :version
    attr_accessor :mode
    attr_accessor :name
    attr_accessor :slug
    attr_accessor :authUrl
    attr_accessor :loginUrl
    attr_accessor :registerUrl
    attr_accessor :logoutUrl
    attr_accessor :oauthLoginUrl
    attr_accessor :oauthLogoutUrl
    attr_accessor :postloc_time_rate
    attr_accessor :postloc_dist_rate
    attr_accessor :curloc_time_rate
    attr_accessor :lon
    attr_accessor :lat
    attr_accessor :timezone
    attr_accessor :time
    attr_accessor :timeoffset
    attr_accessor :datefmt
    attr_accessor :getRouteJourneyIdsUrl
    attr_accessor :getRouteDefinitionUrl
    attr_accessor :getJourneyLocationUrl
    attr_accessor :getMultipleJourneyLocationsUrl
    attr_accessor :postJourneyLocationUrl
    attr_accessor :getMessageUrl
    attr_accessor :getMessagesUrl
    attr_accessor :getMarkersUrl
    attr_accessor :postFeedbackUrl
    attr_accessor :updateUrl
    attr_accessor :updateRate
    attr_accessor :activeStartDisplayThreshold
    attr_accessor :activeEndWaitThreshold
    attr_accessor :offRouteDistanceThreshold
    attr_accessor :offRouteCountThreshold
    attr_accessor :offRouteTimeThreshold
    attr_accessor :getRouteJourneyIds1Url
    attr_accessor :syncRate
    attr_accessor :box
    attr_accessor :markerClickThru
    attr_accessor :messageClickThru
    attr_accessor :bannerRefreshRate
    attr_accessor :bannerClickThru
    attr_accessor :bannerMaxImageSize
    attr_accessor :bannerImageUrl
    attr_accessor :helpUrl
    attr_accessor :initialMessages

    def initialize
      self.initialMessages = []
    end
  end
end