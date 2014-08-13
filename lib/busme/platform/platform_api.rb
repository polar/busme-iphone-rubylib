module Platform
  class PlatformApi < Api::BuspassAPI
    attr_accessor :bgEvents
    attr_accessor :uiEvents

    def initialize(*arguments)
      super
      self.bgEvents = Api::BuspassEventDistributor.new
      self.uiEvents = Api::BuspassEventDistributor.new
    end
  end
end