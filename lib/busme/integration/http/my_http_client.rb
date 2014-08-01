module Integration
  module Http
    class MyHttpClient
      attr_accessor :httpClient
      def initialize
        self.httpClient = HTTPClient.new
      end

      def getURLResponse(url)
        message = httpClient.get(url)
        HttpResponse.new(message)
      end

      def openURL(url)
        message = httpClient.get(url)
        HttpEntity.new(message)
      end

      def postURLResponse(url, params)
        message = httpClient.post(url, params)
        HttpResponse.new(message)
      end

      def postURL(url, params)
        message = httpClient.post(url, params)
        HttpEntity.new(message)
      end

      def postDeleteURL(url)
        message = httpClient.delete(url)
        HttpEntity.new(message)
      end
    end
end
end