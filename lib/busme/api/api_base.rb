require "httpclient"

module Api
  class APIBase
    attr_accessor :http_client

    def initialize
      self.http_client = Integration::Http::MyHttpClient.new
    end

    def openURL(url)
      http_client.openURL(url)
    end

    def getURLResponse(url)
      http_client.getURLResponse(url)
    end

    def postURL(url, params)
      http_client.postURL(url, params)
    end

    def postURLResponse(url, params)
      http_client.postURLResponse(url, params)
    end

    def postDeleteURL(url)
      http_client.postDeleteURL(url)
    end

    def xmlParse(entity)
      doc = REXML::Document.new(entity.getContent())
      Api::Tag.new(doc.root)
    end
  end
end