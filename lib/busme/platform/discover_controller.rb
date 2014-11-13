module Platform
  class DiscoverEventData
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

  class DiscoverController
    attr_accessor :api
    attr_accessor :masters
    attr_accessor :mainController

    def initialize(args)
      self.api = args.delete :api
      self.mainController = args.delete :mainController

      mainController.bgEvents.registerForEvent("Search:init", self)
      mainController.bgEvents.registerForEvent("Search:discover", self)
      mainController.bgEvents.registerForEvent("Search:find", self)
      mainController.bgEvents.registerForEvent("Search:select", self)
    end

    def unregisterForEvents
      mainController.bgEvents.unregisterForEvent("Search:init", self)
      mainController.bgEvents.unregisterForEvent("Search:discover", self)
      mainController.bgEvents.unregisterForEvent("Search:find", self)
      mainController.bgEvents.unregisterForEvent("Search:select", self)
    end

    def onBuspassEvent(event)
      case event.eventName
        when "Search:init"
          onSearchInitEvent(event)
        when "Search:discover"
          onSearchDiscoverEvent(event)
        when "Search:find"
          onSearchFindEvent(event)
        when "Search:select"
          onSearchSelectEvent(event)
      end
    end

    def onSearchInitEvent(event)
      evd = event.eventData
      self.masters = []
      evd.controller = self
      evd.return = api.get
    rescue Exception => boom
      evd.error = boom
    ensure
      mainController.uiEvents.postEvent("Search:Init:return", evd)
    end

    def onSearchDiscoverEvent(event)
      evd = event.eventData
      evd.controller = self
      # Returns only the masters that have been added.
      evd.return = doDiscover(evd.data)
    rescue Exception => boom
      evd.error = boom
    ensure
      mainController.uiEvents.postEvent("Search:Discover:return", evd)
    end

    def onSearchFindEvent(event)
      evd = event.eventData
      evd.controller = self
      # Returns only the masters that have been added.
      evd.return = doFind(evd.data)
    rescue Exception => boom
      evd.error = boom
    ensure
      mainController.uiEvents.postEvent("Search:Find:return", evd)
    end

    def onSearchSelectEvent(event)
      evd = event.eventData
      evd.controller = self
      evd.return = mainController.switchMaster(evd.data[:master], evd.data[:masterApi], evd.data[:saveAsDefault])
    rescue Exception => boom
      evd.error = boom
    ensure
      mainController.uiEvents.postEvent("Search:Select:return", evd)
    end

    def doDiscover(args)
      ms = api.discoverWithArgs(args)
      nms = []
      if ms
        slugs = masters.map {|x| x.slug}
        nms = ms.reject {|x| slugs.include?(x.slug) }
        self.masters += nms
      end
      nms
    end

    def doFind(args)
     #puts "doFind #{args.inspect} from #{masters.count} masters"
      loc = args[:loc]
      selected = []
      masters.each do |master|
        bs = master.bbox.map {|x| (x * 1E6).to_i} # W, N, E, S
        bbox = Integration::BoundingBoxE6.new(bs[1],bs[2],bs[3],bs[0]) # N, E, S, W
        r = Integration::Rect.new(bbox.westE6, bbox.northE6, bbox.eastE6, bbox.southE6) # L T R B
        x = (loc.longitude * 1E6).to_i
        y = (loc.latitude * 1E6).to_i
        if r.containsXY(x,y)
         #puts "Hit #{master.slug} (#{x},#{y}) in #{r}"
          selected << [r, master]
        else
         #puts "NoHit #{master.slug} (#{x},#{y}) in #{r}"
        end
      end
      _, master = selected.sort {|v1,v2| v1[0].area <=> v2[0].area}.first
      master
    end
  end
end