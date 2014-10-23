module Platform

  class MainEventData
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

  class MainController
    attr_accessor :directory
    attr_accessor :discoverApi
    attr_accessor :masterApi
    attr_accessor :bgEvents
    attr_accessor :uiEvents
    attr_accessor :masterController
    attr_accessor :discoverController

    def initialize(args = {})
      self.directory = args[:directory]

      self.bgEvents = Api::BuspassEventDistributor.new(:name => "BGEvents:Main")
      self.uiEvents = Api::BuspassEventDistributor.new(:name => "UIEvents:Main")

      bgEvents.registerForEvent("Main:Discover:init", self)
      bgEvents.registerForEvent("Main:Master:init", self)
    end

    def onBuspassEvent(event)
      case event.eventName
        when "Main:Discover:init"
          onDiscoverInitEvent(event)
        when "Main:Master:init"
          onMasterInitEvent(event)
      end
    end

    def onDiscoverInitEvent(event)
      evd = event.eventData
      evd.controller = self
      oldDiscoverController = discoverController
      api = evd.data[:discoverApi]
      self.discoverController = DiscoverController.new(api: api, mainController: self)
      evd.return = discoverController
      if discoverController
        self.discoverApi = api
        if oldDiscoverController
          oldDiscoverController.unregisterForEvents
        end
      end
    rescue Exception => boom
      self.discoverController = oldDiscoverController
      evd.error = boom
    ensure
      uiEvents.postEvent("Main:Discover:Init:return", evd)
    end

    def onMasterInitEvent(event)
      evd = event.eventData
      evd.controller = self
      api = evd.data[:masterApi]
      master = evd.data[:master]
      evd.return = switchMaster(master, api)
    rescue Exception => boom
      self.masterController = oldMasterController
      evd.error = boom
    ensure
      uiEvents.postEvent("Main:Master:Init:return", evd)
    end

    def switchMaster(master, api)
      oldMasterController = masterController
      if oldMasterController
        oldMasterController.storeMaster
      end
      self.masterController = MasterController.new(api: api, master: master, mainController: self)
      if masterController
        self.masterApi = api
        if oldMasterController
          oldMasterController.unregisterForEvents
        end
      end
      masterController
    rescue Exception => boom
      self.masterController = oldMasterController
      raise boom
    end

  end
end