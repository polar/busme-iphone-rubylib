module Platform

  class UpdateEventData < JourneySyncEventData
    attr_accessor :pleaseStop
    def initialize(args = {})
      self.pleaseStop = args[:pleaseStop]
      super(args)
    end
  end

end