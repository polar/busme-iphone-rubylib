module Platform
  class Guts
    attr_accessor :api
    attr_accessor :discoverApi

    attr_accessor :bannerBasket
    attr_accessor :bannerPresentationController
    attr_accessor :bannerStore

    attr_accessor :journeyBasket
    attr_accessor :journeyDisplayController
    attr_accessor :journeyStore
    attr_accessor :journeyVisibilityController

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

    attr_accessor :bgJourneySyncController

    attr_accessor :bgUpdateRemoteInvocationEventController

    attr_accessor :bgBannerMessageEventController
    attr_accessor :bgMarkerMessageEventController
    attr_accessor :bgMasterMessageEventController

    attr_accessor :busmeLocatorController

    attr_accessor :fgBannerPresentationEventController
    attr_accessor :fgMarkerPresentationEventController

    attr_accessor :fgBannerMessageEventController
    attr_accessor :fgMarkerMessageEventController
    attr_accessor :fgMasterMessageEventController
    attr_accessor :fgJourneySyncProgressEventController
    attr_accessor :fgBusmeLocatorController

    attr_accessor :busmeApiController

    def initialize(args)
      self.api = args[:api]
      self.discoverApi = args[:discoverApi]

      self.bannerPresentationController = BannerPresentationController.new(api)
      self.bannerStore = BannerStore.new
      self.bannerBasket = BannerBasket.new(bannerStore, bannerPresentationController)

      self.journeyStore = JourneyStore.new # TODO: Serialization
      self.journeyBasket = JourneyBasket.new(api, journeyStore)
      # Posts JourneyAdded and JourneyRemoved UI Events
      self.journeyDisplayController = JourneyDisplayController.new(api, journeyBasket)

      self.journeyVisibilityController = JourneyVisibilityController.new(api, journeyDisplayController)

      self.markerPresentationController = MarkerPresentationController.new
      self.markerStore = MarkerStore.new # TODO: Serialization
      self.markerBasket = MarkerBasket.new(markerStore, markerPresentationController)

      self.masterMessageStore = MasterMessageStore.new # TODO: Serialization
      self.masterMessageController = MasterMessageController.new(api)
      self.masterMessageBasket = MasterMessageBasket.new(masterMessageStore, masterMessageController)

      self.loginBackground = LoginBackground.new(api)

      self.journeyLocationPoster = JourneyLocationPoster.new(api)
      self.journeyEventController = JourneyEventController.new(api)
      self.journeyPostingController = JourneyPostingController.new(api)

      # Fires on BG Event "BusmeApi:get"
      self.busmeApiController = BusmeApiController.new(guts: self)
      # Fires on a BG EVent "Update"
      self.updateRemoteInvocation = UpdateRemoteInvocation.new(self)

      self.externalStorageController = ExternalStorageController.new(api) # TODO: Extend for platform
      self.storageSerializerController = StorageSerializerController.new(api, externalStorageController)

      self.bgJourneySyncController = BG_JourneySyncController.new(api, journeyDisplayController)
      self.bgUpdateRemoteInvocationEventController = BG_UpdateRemoteInvocationEventController.new(api, updateRemoteInvocation)
      self.bgBannerMessageEventController = BG_BannerMessageEventController.new(api)
      self.bgMarkerMessageEventController = BG_MarkerMessageEventController.new(api)
      self.bgMasterMessageEventController = BG_MasterMessageEventController.new(api)

      # TODO: Extend all below for Platform UI

      self.loginForeground = LoginForeground.new(api) # TODO: Extend with UI

      self.fgBannerPresentationEventController = FG_BannerPresentationEventController.new(api)
      self.fgMarkerPresentationEventController = FG_MarkerPresentationEventController.new(api)

      self.fgBannerMessageEventController = FG_BannerMessageEventController.new(api)
      self.fgMarkerMessageEventController = FG_MarkerMessageEventController.new(api, markerPresentationController)
      self.fgMasterMessageEventController = FG_MasterMessageEventController.new(api)
      self.fgJourneySyncProgressEventController = FG_JourneySyncProgressEventController.new(api)

      # Some tests don't require a discover API.
      if discoverApi
        self.busmeLocatorController = BusmeLocatorController.new(discoverApi)
        self.fgBusmeLocatorController = FGBusmeLocatorController.new(discoverApi)
      end

    end

    def reinitializeAPI(args)
      # We install new event Distributors because the old ones still hold
      # on to the event handlers.
      self.api = args.delete :api

      self.bannerPresentationController = BannerPresentationController.new(api)
      self.bannerStore = BannerStore.new
      self.bannerBasket = BannerBasket.new(bannerStore, bannerPresentationController)

      self.journeyStore = JourneyStore.new
      self.journeyBasket = JourneyBasket.new(api, journeyStore)
      # Posts JourneyAdded and JourneyRemoved UI Events
      self.journeyDisplayController = JourneyDisplayController.new(api, journeyBasket)

      self.journeyVisibilityController = JourneyVisibilityController.new(api, journeyDisplayController)

      self.markerPresentationController = MarkerPresentationController.new
      self.markerStore = MarkerStore.new
      self.markerBasket = MarkerBasket.new(markerStore, markerPresentationController)

      self.masterMessageStore = MasterMessageStore.new
      self.masterMessageController = MasterMessageController.new(api)
      self.masterMessageBasket = MasterMessageBasket.new(masterMessageStore, masterMessageController)
      self.loginBackground = LoginBackground.new(api)

      self.journeyLocationPoster = JourneyLocationPoster.new(api)
      self.journeyEventController = JourneyEventController.new(api)
      self.journeyPostingController = JourneyPostingController.new(api)

      # Fires on BG Event "BusmeApi:get"
      self.busmeApiController = BusmeApiController.new(guts: self)
      # Fires on a BG EVent "Update"
      self.updateRemoteInvocation = UpdateRemoteInvocation.new(self)

      self.externalStorageController = ExternalStorageController.new(api)
      self.storageSerializerController = StorageSerializerController.new(api, externalStorageController)

      self.bgJourneySyncController = BG_JourneySyncController.new(api, journeyDisplayController)
      self.bgUpdateRemoteInvocationEventController = BG_UpdateRemoteInvocationEventController.new(api, updateRemoteInvocation)
      self.bgBannerMessageEventController = BG_BannerMessageEventController.new(api)
      self.bgMarkerMessageEventController = BG_MarkerMessageEventController.new(api)
      self.bgMasterMessageEventController = BG_MasterMessageEventController.new(api)

      self.externalStorageController.directory = args.delete :directory

      # TODO: UI Components.
    end

    def storeMasterApi
      if api.ready
        journeyStore.preSerialize(api)
        storageSerializerController.cacheStorage(journeyStore, "#{api.buspass.slug}-Journeys.xml", api)
        journeyStore.postSerialize(api)
        markerStore.preSerialize(api)
        storageSerializerController.cacheStorage(markerStore, "#{api.buspass.slug}-Markers.xml", api)
        markerStore.postSerialize(api)
        masterMessageStore.preSerialize(api)
        storageSerializerController.cacheStorage(masterMessageStore, "#{api.buspass.slug}-Messages.xml", api)
        masterMessageStore.postSerialize(api)
      else
        puts "Guts.storeApi: API not ready"
      end
    end

    def getMasterApi
      get = api.get
      if api.ready
        js = storageSerializerController.retrieveStorage("#{api.buspass.slug}-Journeys.xml", api)
        if js
          self.journeyStore = js
          self.journeyBasket = JourneyBasket.new(api, journeyStore)
          self.journeyDisplayController = JourneyDisplayController.new(api, journeyBasket)
          self.journeyVisibilityController = JourneyVisibilityController.new(api, journeyDisplayController)
        end
        ms = storageSerializerController.retrieveStorage("#{api.buspass.slug}-Messages.xml", api)
        if ms
          self.masterMessageStore = ms
          self.masterMessageController = MasterMessageController.new(api)
          self.masterMessageBasket = MasterMessageBasket.new(masterMessageStore, masterMessageController)
        end
        ks = storageSerializerController.retrieveStorage("#{api.buspass.slug}-Markers.xml", api)
        if ks
          self.markerStore = ks
          self.markerBasket = MarkerBasket.new(markerStore, markerPresentationController)
        end
      else
        puts "Guts.getMasterApi: API not ready"
      end
      get
    end
  end
end