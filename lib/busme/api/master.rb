module Api
  class Master
    include Encoding
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

    def valid?
      #puts "Master:valid #{self.to_s}"
      (!(propList - ["@time_format"]).any? {|x| instance_variable_get(x).nil?}).tap do |x|
        #puts "Master:.valid == #{x}"
      end
    end

    def to_s
      StringIO.new("<Api::Master:#{__id__}").tap do |s|
        propList.each do |prop|
          s.write(" #{prop}=#{instance_variable_get(prop).inspect}")
        end
        s.write(">")
      end.string
    end
  end


end