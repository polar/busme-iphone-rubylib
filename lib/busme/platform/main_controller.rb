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
    attr_accessor :busmeConfigurator
    attr_accessor :directory
    attr_accessor :discoverApi
    attr_accessor :masterApi
    attr_accessor :bgEvents
    attr_accessor :uiEvents
    attr_accessor :masterController
    attr_accessor :discoverController
    attr_accessor :loginManager

    def initialize(args = {})
      self.directory = args[:directory]
      self.busmeConfigurator = args[:busmeConfigurator] || BusmeConfigurator.new

      self.bgEvents = Api::BuspassEventDistributor.new(:name => "BGEvents:Main")
      self.uiEvents = Api::BuspassEventDistributor.new(:name => "UIEvents:Main")

      uiEvents.registerForEvent("Main:init", self)
      bgEvents.registerForEvent("Main:Discover:init", self)
      bgEvents.registerForEvent("Main:Master:init", self)
    end

    def onBuspassEvent(event)
      PM.logger.info "#{self.class.name}:#{__method__}(#{event.eventName})"
      case event.eventName
        when "Main:init"
          onInitEvent(event)
        when "Main:Discover:init"
          onDiscoverInitEvent(event)
        when "Main:Master:init"
          onMasterInitEvent(event)
      end
    end

    def onInitEvent(event)
      evd = event.eventData
      evd.controller = self
      PM.logger.info "#{self.class.name}:#{__method__}(#{event.eventName}) #{evd.controller}"
      defaultMaster = busmeConfigurator.getDefaultMaster()
      PM.logger.info "#{self.class.name}:#{__method__}(#{event.eventName}) defaultMaster #{defaultMaster}"
      if defaultMaster && defaultMaster.valid?
        evd.data = { :master => defaultMaster }
        evd.return = "defaultMaster"
      else
        PM.logger.info "#{self.class.name}:#{__method__}(#{event.eventName}) getting last location"
        location = busmeConfigurator.getLastLocation()
        PM.logger.info "#{self.class.name}:#{__method__}(#{event.eventName}) location #{location}"
        evd.data = { lastLocation: location }
        evd.return = "discover"
      end
    rescue Exception => boom
      evd.error = boom
    ensure
      uiEvents.postEvent("Main:Init:return", evd)
      PM.logger.info "#{self.class.name}:#{__method__}(#{event.eventName}) #{evd.return}"
    end

    def onDiscoverInitEvent(event)
      evd = event.eventData
      evd.controller = self
      oldDiscoverController = discoverController
      api = evd.data[:discoverApi]
      loc = evd.data[:location]
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
      saveAsDefault = evd.data[:saveAsDefault]
      evd.return = switchMaster(master, api, saveAsDefault)
    rescue Exception => boom
      evd.error = boom
    ensure
      uiEvents.postEvent("Main:Master:Init:return", evd)
    end

    def switchMaster(master, api, saveAsDefault)
      oldMasterController = masterController
      if oldMasterController
        oldMasterController.storeMaster
      end
      self.masterController = instantiateMasterController(api: api, master: master, mainController: self)
      if masterController
        self.masterApi = api
        if oldMasterController
          oldMasterController.unregisterForEvents
        end
        if saveAsDefault
          busmeConfigurator.saveAsDefaultMaster(master)
        end
      end
      [masterController, oldMasterController]
    rescue Exception => boom
      self.masterController = oldMasterController
      raise boom
    end

    def instantiateMasterController(args)
      api = args[:api]
      master = args[:master]
      controller = args[:mainController] || self
      MasterController.new(api: api, master: master, mainController: controller)
    end



  end
end