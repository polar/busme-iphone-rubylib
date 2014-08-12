module Integration
  module Http
    class StatusLine
      attr_accessor :reasonPhrase
      attr_accessor :statusCode
      def initialize(code, reason)
        self.statusCode = code
        self.reasonPhrase = reason
      end
    end
end
end