module Platform
  class Guts
    attr_accessor :api

    attr_accessor :bannerBasket
    attr_accessor :bannerController
    attr_accessor :bannerStore
    attr_accessor :bannerForeground
    attr_accessor :bannerBackground

    attr_accessor :journeyBasket
    attr_accessor :journeyDisplayController
    attr_accessor :journeyStore

    attr_accessor :markerBasket
    attr_accessor :markerController
    attr_accessor :markerStore
    attr_accessor :markerMessageForeground
    attr_accessor :markerMessageBackground

    attr_accessor :masterMessageBasket
    attr_accessor :masterMessageController
    attr_accessor :masterMessageStore
    attr_accessor :masterMessageForeground
    attr_accessor :masterMessageBackground

    attr_accessor :loginForeground
    attr_accessor :loginBackground

    def initialize(api)
      api = api

      self.bannerController = BannerController.new(api) # TODO: Extend with UI
      self.bannerStore = BannerStore.new
      self.bannerBasket = BannerBasket.new(bannerStore, bannerController)
      self.bannerForeground = BannerForeground.new(api)
      self.bannerBackground = BannerBackground.new(api)

      self.journeyStore = JourneyStore.new # TODO: Serialization
      self.journeyBasket = JourneyBasket.new(api, journeyStore)
      self.journeyDisplayController = JourneyDisplayController.new(journeyBasket) # TODO: Extend with UI

      self.markerController = MarkerController.new # TODO: Extend with UI
      self.markerStore = MarkerStore.new # TODO: Serialization
      self.markerBasket = MarkerBasket.new(markerStore, markerController)
      self.markerMessageForeground = MarkerMessageForeground.new(api, markerController)
      self.markerMessageBackground =  MarkerMessageBackground.new(api)

      self.masterMessageStore = MasterMessageStore.new # TODO: Serialization
      self.masterMessageController = MasterMessageController.new(api)
      self.masterMessageBasket = MasterMessageBasket.new(masterMessageStore, masterMessageController)
      self.masterMessageForeground = MasterMessageForeground.new(api) # TODO: Extend with UI
      self.masterMessageBackground =  MasterMessageBackground.new(api)

      self.loginForeground = LoginForeground.new(api) # TODO: Extend with UI
      self.loginBackground = LoginBackground.new(api)
    end
  end
end