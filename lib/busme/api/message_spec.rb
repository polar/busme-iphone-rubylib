module Api
  class MessageSpec
    attr_accessor :id
    attr_accessor :version
    attr_accessor :expiryTime

    def initialize(id, version, expiryTime)
      self.id = id
      self.version = version
      self.expiryTime = expiryTime
    end
  end
end