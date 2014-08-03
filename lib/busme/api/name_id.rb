module Api
  class NameId
    attr_accessor :name
    attr_accessor :id
    attr_accessor :route_id
    attr_accessor :type
    attr_accessor :version
    attr_accessor :sched_time_start
    attr_accessor :time_start

    def init_name_id(name, id)
      self.name = name.strip
      self.id = id.strip
    end

    def initialize(*arguments)
      if arguments[0].is_a?(Array)
        init_struct(arguments)
      else
        init_name_id(arguments[0], arguments[1])
      end
    end


  end
end