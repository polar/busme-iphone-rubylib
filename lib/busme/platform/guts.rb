module Platform
  class Guts
    attr_accessor :api

    attr_accessor :bannerBasket
    attr_accessor :bannerController
    attr_accessor :bannerStore
    attr_accessor :bannerClick
    attr_accessor :bannerClicked

    attr_accessor :journeyBasket
    attr_accessor :journeyDisplayController
    attr_accessor :journeyStore

    attr_accessor :markerBasket
    attr_accessor :markerController
    attr_accessor :markerStore

    attr_accessor :masterMessageBasket
    attr_accessor :masterMessageController
    attr_accessor :masterMessageStore

    def initialize(api)
      api = api

      self.bannerController = BannerController.new # TODO: Extend with UI
      self.bannerStore = BannerStore.new
      self.bannerBasket = BannerBasket.new(bannerStore, bannerController)
      self.bannerClick = BannerClick.new(api)
      self.bannerClicked = BannerClicked.new(api)

      self.journeyStore = JourneyStore.new # TODO: Serialization
      self.journeyBasket = JourneyBasket.new(api, journeyStore)
      self.journeyDisplayController = JourneyDisplayController.new(journeyBasket) # TODO: Extend with UI

      self.markerController = MarkerController.new # TODO: Extend with UI
      self.markerStore = MarkerStore.new # TODO: Serialization
      self.markerBasket = MarkerBasket.new(markerStore, markerController)

      self.masterMessageStore = MasterMessageStore.new # TODO: Serialization
      self.masterMessageController = MasterMessageController.new # TODO: Extend with UI
      self.masterMessageBasket = MasterMessageBasket.new(masterMessageStore, masterMessageController)

    end
  end
end