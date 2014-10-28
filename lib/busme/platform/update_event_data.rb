module Platform

  class UpdateEventData < JourneySyncEventData
    attr_accessor :pleaseStop
    def initialize(args = {})
      puts "UpdateEventData.new #{args.inspect}"
      self.pleaseStop = args[:pleaseStop]
      super(args)
      puts "UpdateEventData.new DONE"
      self
    end
  end

end