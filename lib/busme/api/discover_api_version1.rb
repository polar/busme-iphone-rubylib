module Api
  class DiscoverAPIVersion1  < DiscoverAPI
    attr_accessor :initialUrl
    attr_accessor :discoverUrl

    def initialize(url)
      self.initialUrl = url
    end

    def get
      ent = openURL(initialUrl)
      tag = xmlParse(ent)
      if "API" == tag.name
        version = tag.attributes["version"]
        if "d1" == version || "td1" == version
          self.discoverUrl = tag.attributes["discover"]
          self.masterUrl = tag.attributes["master"]
          return true
        end
      end
      return false
    end

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
      url = "#{initialUrl}?lon=#{lon}&lat=#{lat}&buf=#{buffer}"
      ent = openURL(url)
      tag = xmlParse(ent)
      masters = []
      if "masters" == tag.name.downcase
        for t in tag.childNodes do
          if "master" == t.name.downcase
            m = parse_maser(t)
            masters << m
          end
        end
      end
      return masters
    end

    def find_master(slug)
      url = "#{masterUrl}?slug=#{slug}"
      ent = openURL(url)
      tag = xmlParse(ent)
      if tag && "master" == tag.name.downcase
        parse_master(tag)
      end
    end

    private

    def parse_master(tag)
      m = Master.new
      m.lon = t.attributes["lon"].to_f
      m.lat = t.attributes["lat"].to_f
      m.name = t.attributes["name"]
      m.slug = t.attributes["slug"]
      m.apiUrl = t.attributes["api"]
      bounds = t.attributes["api"]
      box = bounds.split(",")
      if box.length == 4
        m.bbox = box.map {|x| x.to_f}
      end
      for child in t.childNodes do
        if "title" == child.name.downcase
          m.title  = child.text
        end
        if "description" == child.name.downcase
          m.description = child.text
        end
      end
    end

  end
end