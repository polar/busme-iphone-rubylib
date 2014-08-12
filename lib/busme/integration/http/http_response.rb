module Integration
  module Http
    class HttpResponse
      attr_accessor :httpResponse
      def initialize(httpResponse)
        self.httpResponse = httpResponse
      end
      def getAllHeaders()
        @headers ||= httpResponse.header.items.map {|k,v| Header.new(k,v)}
      end
      def getEntity()
        @entity ||= HttpEntity.new(httpResponse)
      end
      def getStatusLine()
        @status_line ||= StatusLine.new(httpResponse.header.status_code, httpResponse.header.reason_phrase)
      end
    end
end
end