module Integration
  module Http
    class HttpEntity
      attr_accessor :response

      def initialize(response)
        self.response = response
      end

      def getContentLength
        response.body.length
      end

      def consumeContent

      end

      def getContent
        response.body.to_s
      end
    end
end
end