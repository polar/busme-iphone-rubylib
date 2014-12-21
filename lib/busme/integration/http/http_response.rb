module Integration
  module Http
    class HttpResponse
      def initialize(httpResponse)
        @headers = httpResponse.header.items.map {|k,v| Header.new(k,v)}
        @entity = HttpEntity.new(httpResponse)
        @statusLine = StatusLine.new(httpResponse.header.status_code, httpResponse.header.reason_phrase)
      end
      def getAllHeaders()
        @headers
      end
      def getEntity()
        @entity
      end
      def getStatusLine()
        @statusLine
      end
    end
end
end