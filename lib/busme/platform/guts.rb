module Platform
  class Guts
    attr_accessor :api

    attr_accessor :bannerBasket
    attr_accessor :bannerPresentationController
    attr_accessor :bannerStore

    attr_accessor :journeyBasket
    attr_accessor :journeyDisplayController
    attr_accessor :journeyStore

    attr_accessor :markerBasket
    attr_accessor :markerPresentationController
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

    attr_accessor :bgBannerMessageEventController
    attr_accessor :bgMarkerMessageEventController
    attr_accessor :bgMasterMessageEventController

    attr_accessor :fgBannerPresentationEventController
    attr_accessor :fgMarkerPresentationEventController

    attr_accessor :fgBannerMessageEventController
    attr_accessor :fgMarkerMessageEventController
    attr_accessor :fgMasterMessageEventController

    def initialize(api)
      self.api = api

      self.bannerPresentationController = BannerPresentationController.new(api) # TODO: Extend with UI
      self.bannerStore = BannerStore.new
      self.bannerBasket = BannerBasket.new(bannerStore, bannerPresentationController)

      self.journeyStore = JourneyStore.new # TODO: Serialization
      self.journeyBasket = JourneyBasket.new(api, journeyStore)
      self.journeyDisplayController = JourneyDisplayController.new(api, journeyBasket) # TODO: Extend with UI

      self.markerPresentationController = MarkerPresentationController.new # TODO: Extend with UI
      self.markerStore = MarkerStore.new # TODO: Serialization
      self.markerBasket = MarkerBasket.new(markerStore, markerPresentationController)

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

      self.bgBannerMessageEventController = BG_BannerMessageEventController.new(api)
      self.bgMarkerMessageEventController = BG_MarkerMessageEventController.new(api)
      self.bgMasterMessageEventController = BG_MasterMessageEventController.new(api)

      # TODO: Extend all below for Platform UI
      self.fgBannerPresentationEventController = FG_BannerPresentationEventController.new(api)
      self.fgMarkerPresentationEventController = FG_MarkerPresentationEventController.new(api)

      self.fgBannerMessageEventController = FG_BannerMessageEventController.new(api)
      self.fgMarkerMessageEventController = FG_MarkerMessageEventController.new(api, markerPresentationController)
      self.fgMasterMessageEventController = FG_MasterMessageEventController.new(api)

    end
  end
end