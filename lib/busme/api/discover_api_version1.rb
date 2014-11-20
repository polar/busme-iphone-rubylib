module Api
  class DiscoverAPIVersion1  < DiscoverAPI
    attr_accessor :initialUrl
    attr_accessor :discoverUrl
    attr_accessor :masterUrl
    attr_accessor :bgEvents
    attr_accessor :uiEvents

    def initialize(httpClient, url, bgEvents = nil, uiEvents = nil)
      super(httpClient)
      self.initialUrl = url
      self.bgEvents = bgEvents || BuspassEventDistributor.new(:name => "BGEvents")
      self.uiEvents = uiEvents || BuspassEventDistributor.new(:name => "UIEvents")
    end

    def get
      resp = getURLResponse(initialUrl)
      if resp.getStatusLine.statusCode.to_i == 200
        ent = resp.getEntity()
        if ent
          tag = xmlParse(ent)
          if tag && "api" == tag.name.downcase
            version = tag.attributes["version"]
            if "d1" == version || "td1" == version
              self.discoverUrl = tag.attributes["discover"]
              self.masterUrl = tag.attributes["master"]
              return self
            else
              Integration::Http::StatusLine.new(500, "Incorrect Version: Discover Api")
            end
          else
            Integration::Http::StatusLine.new(500, "Bad Response from Server")
          end
        else
          puts "No Answer from #{initialUrl}"
          Integration::Http::StatusLine.new(500, "Internal App Error")
        end
      else
        resp.getStatusLine
      end
    rescue Exception => boom
      Integration::Http::StatusLine.new(500, "Internal App Error #{boom}")
    end

    # Zoomlevel here is Android specific.
    def discoverZoom(lon, lat, zoomlevel = nil, width = nil, height = nil)
      buffer = 0
      if zoomlevel
        feet_per_pixel = (Platform::GeoCalc::EARTH_RADIUS_FEET * Math.cos(lat)/2^(zoomlevel+8)).abs
        if width
          if !height
            buffer = feet_per_pixel * (0.80 * width)
          else
            buffer = [width, height].min
          end
        end
      end
      discover(lon, lat, buffer)
    end

    def discover(lon, lat, buffer)
      if discoverUrl
        url = "#{discoverUrl}?lon=#{lon}&lat=#{lat}&buf=#{buffer}"
        ent = openURL(url)
        tag = xmlParse(ent)
        masters = []
        if "masters" == tag.name.downcase
          for t in tag.childNodes do
            if "master" == t.name.downcase
              m = parse_master(t)
              masters << m
            end
          end
        end
        return masters
      end
    rescue
      nil
    end

    def find_master(slug)
      url = "#{masterUrl}?slug=#{slug}"
      ent = openURL(url)
      tag = xmlParse(ent)
      if tag && "master" == tag.name.downcase
        parse_master(tag)
      end
    end

    def to_s
      "<#{self.class.name} initialUrl = #{initialUrl}, masterUrl = #{masterUrl}, discoverUrl = #{discoverUrl}>"
    end

    private

    def parse_master(tag)
      master = Master.new
      master.lon = tag.attributes["lon"].to_f
      master.lat = tag.attributes["lat"].to_f
      master.name = tag.attributes["name"]
      master.slug = tag.attributes["slug"]
      master.apiUrl = tag.attributes["api"]
      bounds = tag.attributes["bounds"]
      box = bounds.split(",")
      if box.length == 4
        master.bbox = box.map {|x| x.to_f}
      end
      for child in tag.childNodes do
        if "title" == child.name.downcase
          master.title  = child.text
        end
        if "description" == child.name.downcase
          master.description = child.text
        end
      end
      return master
    end

  end
end