module Api
  class Storage
    attr_accessor :dirty

    def initialize
      @dirty = false
    end

    def preSerialize(api)
      raise "NotImplemented"
    end

    def postSerialize(api)
      raise "NotImplemented"
    end
  end
end