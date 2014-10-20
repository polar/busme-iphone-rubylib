module Platform
  class BusmeLocatorController
    attr_accessor :api
    attr_accessor :masters

    def initialize(discover_api)
      self.api = discover_api
      api.bgEvents.registerForEvent("Locator:get", self)
      api.bgEvents.registerForEvent("Locator:discover", self)
      api.bgEvents.registerForEvent("Locator:select", self)
      self.masters = []
    end

    def onBuspassEvent(event)
      case event.eventName
        when "Locator:get"
          d = event.eventData
          doGet(d)
        when "Locator:discover"
          d = event.eventData
          doDiscover(d)
        when "Locator:select"
          d = event.eventData
          doSelect(d)
      end
    end

    def doDiscover(eventData)
      ms = api.discover(eventData.lon, eventData.lat, eventData.buf)
      if ms
        slugs = masters.map {|x| x.slug}
        nms = ms.reject {|x| slugs.include?(x.slug) }
        self.masters += nms
        eventData.masters = nms
      end
    rescue Exception => boom
        puts boom
    ensure
      api.uiEvents.postEvent("Locator:onDiscover", eventData)
    end

    def doGet(eventData)
      get = api.get
      eventData.get = get
    rescue Exception => boom
      puts boom
    ensure
      api.uiEvents.postEvent("Locator:onGet", eventData)
    end

    def doSelect(eventData)
      puts "onSelect #{eventData.inspect} from #{masters.count} masters"
      loc = eventData
      selected = []
      masters.each do |master|
        bs = master.bbox.map {|x| (x * 1E6).to_i} # W, N, E, S
        bbox = Integration::BoundingBoxE6.new(bs[1],bs[2],bs[3],bs[0]) # N, E, S, W
        r = Integration::Rect.new(bbox.westE6, bbox.northE6, bbox.eastE6, bbox.southE6) # L T R B
        x = (loc.longitude * 1E6).to_i
        y = (loc.latitude * 1E6).to_i
        if r.containsXY(x,y)
          puts "Hit #{master.slug} (#{x},#{y}) in #{r}"
          selected << [r, master]
        else
          puts "NoHit #{master.slug} (#{x},#{y}) in #{r}"
        end
      end
      _, master = selected.sort {|v1,v2| v1[0].area <=> v2[0].area}.first
      if master
        api.uiEvents.postEvent("Map:SetMaster", master)
      end
    rescue Exception => boom
      puts "#{boom}"
    end

  end
end