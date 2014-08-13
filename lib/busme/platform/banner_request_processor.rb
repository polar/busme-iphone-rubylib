module Platform
  class BannerRequestProcessor
    include Api::ArgumentPreparer
    include Api::ResponseProcessor

    attr_accessor :bannerBasket

    def initialize(basket)
      self.bannerBasket = basket
    end

    def getArguments
      if bannerBasket
        params = []
        for message in bannerBasket.getBanners do
          params << ["banner_ids[]", message.id]
          params << ["banner_versions[]", "#{message.version}"]
        end
        params
      end
    end

    def onResponse(response)
      messages = {}
      if response && response.childNodes
        for tag in response.childNodes do
          if "banners" == tag.name.downcase
            for tag1 in  tag.childNodes do
              if "banner" == tag1.name.downcase
                if tag1.attributes["destroy"]
                  messages[tag1.attributes["id"]] = nil
                else
                  message = Api::BannerInfo.new
                  message.loadParsedXML(tag1)
                  messages[message.id] = message
                end
              end
            end
          end
        end
      end
      for id, message in messages do
        if message.nil?
          bannerBasket.removeBanner(id)
        else
          bannerBasket.addBanner(message)
        end
      end
    end
  end
end