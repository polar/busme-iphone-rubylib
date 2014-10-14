module Testlib
  class MyHttpClient < Integration::Http::HttpClient
    attr_accessor :httpClient

    def initialize(httpClient = nil)
      self.httpClient = httpClient || HTTPClient.new
    end

    def getURLResponse(url)
      message = httpClient.get(url)
      Integration::Http::HttpResponse.new(message) if message
    end

    def openURL(url)
      message = httpClient.get(url)
      Integration::Http::HttpEntity.new(message) if message
    end

    def postURLResponse(url, params)
      message = httpClient.post(url, params)
      Integration::Http::HttpResponse.new(message) if message
    end

    def postURL(url, params)
      message = httpClient.post(url, params)
      Integration::Http::HttpEntity.new(message) if message
    end

    def postDeleteURL(url)
      message = httpClient.delete(url)
      Integration::Http::HttpEntity.new(BWrap.new(message))
    end

    def mock_answer
      httpClient.mock_answer
    end
    def mock_answer=(x)
      httpClient.mock_answer = x
    end
  end
end