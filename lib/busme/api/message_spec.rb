module Api
  class MessageSpec
    attr_accessor :id
    attr_accessor :version
    attr_accessor :expiryTime

    def propList
      %w(
    @id
    @version
    @expiryTime

      )
    end
    def initWithCoder1(decoder)
      self.id = decoder[:id]
      self.version = decoder[:version]
      self.expiryTime = decoder[:expiryTime]
      self
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end
    def encodeWithCoder1(encoder)
      encoder[:id] = id
      encoder[:version] = version
      encoder[:expiryTime] = expiryTime
    rescue Exception => boom
      puts "#{boom}"
      p boom.backtrace
    end

    def initialize(id, version, expiryTime)
      self.id = id
      self.version = version
      self.expiryTime = expiryTime
    end
  end
end