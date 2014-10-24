module Api
  module Storage
    include Encoding
    def preSerialize(api, time = nil)
      raise "NotImplemented"
    end

    def postSerialize(api, time = nil)
      raise "NotImplemented"
    end
  end
end