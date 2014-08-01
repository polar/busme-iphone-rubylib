module Integration
  module Http
    class StatusLine
      attr_accessor :reasonPhrase
      attr_accessor :statusCode
    end

      def initialize(code, phrase)
        self.reasonPhrase = phrase
        self.statusCode = code
    end
end
end