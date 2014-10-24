module Api
  class NameId
    include Encoding
    attr_accessor :name
    attr_accessor :id
    attr_accessor :route_id
    attr_accessor :type
    attr_accessor :version
    attr_accessor :sched_time_start
    attr_accessor :time_start
    
    def propList
      %w(
    @name
    @id
    @route_id
    @type
    @version
    @sched_time_start
    @time_start
      )
    end

    def initWithCoder1(decoder)
      self.name = decoder[:name]
      self.id = decoder[:id]
      self.route_id = decoder[:route_id]
      self.type = decoder[:type]
      self.version = decoder[:version]
      self.sched_time_start = decoder[:sched_time_start]
      self.time_start = decoder[:time_start]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def encodeWithCoder1(encoder)
      encoder[:name] = name
      encoder[:id] = id
      encoder[:route_id] = route_id
      encoder[:type] = type
      encoder[:version] = version
      encoder[:sched_time_start] = sched_time_start
      encoder[:time_start] = time_start
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def initialize(*arguments)
      if arguments[0].is_a?(Array)
        init_struct(arguments[0])
      else
        init_name_id(arguments[0], arguments[1])
      end
    end

    def init_name_id(name, id)
      self.name = name.strip
      self.id = id.strip
    end

    def init_struct(args)
      self.name = args[0].strip
      self.id   = args[1].strip
      if (args.length > 2)
        self.type = args[2].strip
      end
      if "R" == type && args.length == 4
        self.version = args[3].to_i
      elsif "V" == type && args.length > 4
        self.route_id = args[3].strip
        self.version = args[4].to_i
        if args.length > 5
          self.sched_time_start = args[5].to_i
          self.time_start = args[6].to_i
        end
      end
    end
  end
end