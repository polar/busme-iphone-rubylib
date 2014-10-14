module Api
  class APIBase
    attr_accessor :http_client

    def initialize(http_client)
      self.http_client = http_client
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