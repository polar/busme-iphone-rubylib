module Integration
  module Http
    class HttpEntity

      def initialize(response)
        @contentLength = response.body.length
        @content = response.body.to_s
      end

      def getContentLength
        @contentLength
      end

      def consumeContent
        @content = nil
      end

      def getContent
        @content
      end
    end
end
end