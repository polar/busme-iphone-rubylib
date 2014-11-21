module Api
  class HTTPError < Exception
    attr_accessor :statusLine
    def initialize(statusLine)
      self.statusLine = statusLine
    end
  end
end