module Api
  class Master
    attr_accessor :lon
    attr_accessor :lat
    attr_accessor :slug
    attr_accessor :name
    attr_accessor :apiUrl
    attr_accessor :title
    attr_accessor :description
    attr_accessor :bbox
    attr_accessor :time_format
    
    def propList
      %w(
    @lon
    @lat
    @slug
    @name
    @apiUrl
    @title
    @description
    @bbox
    @time_format
      )
    end

    def time_format
      @time_format || "%l:%M %P"
    end

    def initWithCoder1(decoder)
      self.lon = decoder[:lon]
      self.lat = decoder[:lat]
      self.slug = decoder[:slug]
      self.name = decoder[:name]
      self.apiUrl = decoder[:apiUrl]
      self.title = decoder[:title]
      self.description = decoder[:description]
      self.bbox = decoder[:bbox]
      self.time_format = decoder[:time_format]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def encodeWithCoder1(encoder)
      encoder[:lon] = lon
      encoder[:lat] = lat
      encoder[:slug] = slug
      encoder[:name] = name
      encoder[:apiUrl] = apiUrl
      encoder[:title] = title
      encoder[:description] = description
      encoder[:bbox] = bbox
      encoder[:time_format] = @time_format
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
  end
end