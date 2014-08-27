module Platform
  class Guts
    attr_accessor :api

    attr_accessor :bannerBasket
    attr_accessor :bannerController
    attr_accessor :bannerStore

    attr_accessor :journeyBasket
    attr_accessor :journeyDisplayController
    attr_accessor :journeyStore

    attr_accessor :markerBasket
    attr_accessor :markerController
    attr_accessor :markerStore

    attr_accessor :masterMessageBasket
    attr_accessor :masterMessageController
    attr_accessor :masterMessageStore

    attr_accessor :loginForeground
    attr_accessor :loginBackground

    attr_accessor :journeyLocationPoster
    attr_accessor :journeyEventController
    attr_accessor :journeyPostingController

    attr_accessor :updateRemoteInvocation

    attr_accessor :externalStorageController
    attr_accessor :storageSerializerController

    attr_accessor :journeySyncController

    def initialize(api)
      self.api = api

      self.bannerController = BannerPresentationController.new(api) # TODO: Extend with UI
      self.bannerStore = BannerStore.new
      self.bannerBasket = BannerBasket.new(bannerStore, bannerController)

      self.journeyStore = JourneyStore.new # TODO: Serialization
      self.journeyBasket = JourneyBasket.new(api, journeyStore)
      self.journeyDisplayController = JourneyDisplayController.new(api, journeyBasket) # TODO: Extend with UI

      self.markerController = MarkerPresentationController.new # TODO: Extend with UI
      self.markerStore = MarkerStore.new # TODO: Serialization
      self.markerBasket = MarkerBasket.new(markerStore, markerController)

      self.masterMessageStore = MasterMessageStore.new # TODO: Serialization
      self.masterMessageController = MasterMessageController.new(api)
      self.masterMessageBasket = MasterMessageBasket.new(masterMessageStore, masterMessageController)

      self.loginForeground = LoginForeground.new(api) # TODO: Extend with UI
      self.loginBackground = LoginBackground.new(api)

      self.journeyLocationPoster = JourneyLocationPoster.new(api)
      self.journeyEventController = JourneyEventController.new(api)
      self.journeyPostingController = JourneyPostingController.new(api)

      self.updateRemoteInvocation = UpdateRemoteInvocation.new(self)

      self.externalStorageController = ExternalStorageController.new(api) # TODO: Extend for platform
      self.storageSerializerController = StorageSerializerController.new(api, externalStorageController)

      self.journeySyncController = JourneySyncController.new(api, journeyDisplayController)

    end
  end
end