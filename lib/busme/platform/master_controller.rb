module Platform
  class MasterEventData
    attr_accessor :uiData
    attr_accessor :controller
    attr_accessor :data
    attr_accessor :return
    attr_accessor :error
    def initialize(args = {})
      self.uiData = args.delete :uiData
      self.controller = args.delete :controller
      self.data = args.delete :data
      self.return = args.delete :return
      self.error = args.delete :error
    end
  end
  class MasterController
    attr_accessor :api
    attr_accessor :master
    attr_accessor :directory
    attr_accessor :mainController

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

    attr_accessor :locationController

    # Foreground Controllers

    attr_accessor :fgBannerPresentationEventController
    attr_accessor :fgMarkerPresentationEventController
    attr_accessor :fgMasterMessagePresentationEventController

    attr_accessor :fgBannerMessageEventController
    attr_accessor :fgMarkerMessageEventController
    attr_accessor :fgMasterMessageEventController
    attr_accessor :fgJourneySyncProgressEventController
    attr_accessor :fgBusmeLocatorController

    def initialize(args)
      self.api = args.delete :api
      self.master = args.delete :master
      self.mainController = args.delete :mainController
      self.directory = args[:directory] || mainController.directory
      assignStorageSerializerControllers
      assignComponents
      assignBackgroundControllers
      assignForegroundControllers

      api.bgEvents.registerForEvent("Master:init", self)
      api.bgEvents.registerForEvent("Master:reload", self)
    end

    def unregisterForEvents
      api.bgEvents.unregisterForEvent("Master:init", self)
      api.bgEvents.unregisterForEvent("Master:reload", self)
    end

    def onBuspassEvent(event)
      case event.eventName
        when "Master:init"
          doInitEvent(event)
        when "Master:reload"
          doReloadEvent(event)
      end
    end

    def doInitEvent(event)
      evd = event.eventData
      evd.controller = self
      evd.return = api.get
    rescue Exception => boom
      evd.error = boom
    ensure
      api.uiEvents.postEvent("Master:Init:return", evd)
    end

    ##
    # This event happens on the background thread so that it doesn't
    # interfere with an ongoing Sync as the JourneyBasket/JourneyStore
    # combo is not thread safe.
    #
    def doReloadEvent(event)
      # We need to empty the basket first, because that notifies removals, which
      # consequently need the getPattern from the store.
      journeyBasket.empty
      journeyStore.empty
      clearMasterStore
    end

    def assignStorageSerializerControllers
      self.externalStorageController = XMLExternalStorageController.new(masterController: self, api: api) # TODO: Extend for platform
      # YAML StorageSerializer is not used anymore because it must serialize objects that we don't
      # want in the graph. Preserializing them by niling them out and reassigning them is causing reference
      # problems.
      self.storageSerializerController = StorageSerializerController.new(api, externalStorageController)
    end

    def assignComponents
      self.bannerPresentationController = BannerPresentationController.new(api)
      self.bannerStore = BannerStore.new
      self.bannerBasket = BannerBasket.new(bannerStore, bannerPresentationController)

      js = storageSerializerController.retrieveStorage("#{api.master_slug}-Journeys.xml", api)
      self.journeyStore = js || JourneyStore.new
      self.journeyBasket = JourneyBasket.new(api, journeyStore)
      self.journeyDisplayController = JourneyDisplayController.new(api, journeyBasket)
      self.journeyVisibilityController = JourneyVisibilityController.new(api, journeyDisplayController)

      ms = storageSerializerController.retrieveStorage("#{api.master_slug}-Messages.xml", api)
      self.masterMessageStore = ms || MasterMessageStore.new
      self.masterMessageController = MasterMessageController.new(api)
      self.masterMessageBasket = MasterMessageBasket.new(masterMessageStore, masterMessageController)

      self.markerPresentationController = MarkerPresentationController.new(api)
      ks = storageSerializerController.retrieveStorage("#{api.master_slug}-Markers.xml", api)
      self.markerStore = ks || MarkerStore.new
      self.markerBasket = MarkerBasket.new(markerStore, markerPresentationController)
    end

    # These components listen for BuspassEvents on the bgEvents channel.
    def assignBackgroundControllers
      self.loginBackground = LoginBackground.new(api)

      self.journeyLocationPoster = JourneyLocationPoster.new(api)
      self.journeyPostingController = JourneyPostingController.new(api)

      self.updateRemoteInvocation = UpdateRemoteInvocation.new(self)

      self.bgJourneySyncController = BG_JourneySyncController.new(api, journeyDisplayController)
      self.bgUpdateRemoteInvocationEventController =
          BG_UpdateRemoteInvocationEventController.new(
              masterController: self, updateRemoteInvocation: updateRemoteInvocation)

      self.bgBannerMessageEventController = BG_BannerMessageEventController.new(api)
      self.bgMarkerMessageEventController = BG_MarkerMessageEventController.new(api)
      self.bgMasterMessageEventController = BG_MasterMessageEventController.new(api)
      self.locationController = LocationController.new(api, self)
    end

    # These controllers listen for events on the uiEvents channel usually posted by
    # the contained background controllers. Each controller has "present*" methods
    # that are to be extended, and they will get executed on UI thread so that the
    # platform can execute UI operations from there.
    # These are defaults for testing the back and forth protocol between cooresponding
    # background controllers, such with Interactions with messages and login.
    def assignForegroundControllers
      #self.loginForeground = LoginForeground.new(api) # TODO: Extend with UI

      #self.fgBannerPresentationEventController = FG_BannerPresentationEventController.new(api)
      #self.fgMarkerPresentationEventController = FG_MarkerPresentationEventController.new(api)
      #self.fgMasterMessagePresentationEventController = FG_MasterMessagePresentationEventController.new(api)

      self.fgBannerMessageEventController = FG_BannerMessageEventController.new(api)
      self.fgMarkerMessageEventController = FG_MarkerMessageEventController.new(api, markerPresentationController)
      self.fgMasterMessageEventController = FG_MasterMessageEventController.new(api)
      self.fgJourneySyncProgressEventController = FG_JourneySyncProgressEventController.new(api)

      # Extend to provide indications to user for various events that involves posting locations
      # for a particular journey.
      self.journeyEventController = JourneyEventController.new(api)
    end

    # This method stores the our collected information on the external storage of the phone.
    def storeMaster
     #puts "MasterController.storeMaster: "
      if api.isReady?
        # TODO: Do personal login information.
        journeyStore.preSerialize(api)
        storageSerializerController.cacheStorage(journeyStore, "#{api.buspass.slug}-Journeys.xml", api)
        journeyStore.printContents
        journeyStore.postSerialize(api)
        markerStore.preSerialize(api)
        storageSerializerController.cacheStorage(markerStore, "#{api.buspass.slug}-Markers.xml", api)
        markerStore.postSerialize(api)
        masterMessageStore.preSerialize(api)
        storageSerializerController.cacheStorage(masterMessageStore, "#{api.buspass.slug}-Messages.xml", api)
        masterMessageStore.postSerialize(api)
       #puts "MasterController.storeMaster: DONE"
      else
        puts "MasterController.storeMaster: API not ready"
      end
    end

    def clearMasterStore
      storageSerializerController.removeStorage("#{api.buspass.slug}-Journeys.xml")
      storageSerializerController.removeStorage("#{api.buspass.slug}-Markers.xml")
      storageSerializerController.removeStorage("#{api.buspass.slug}-Messages.xml")
    end
  end
end