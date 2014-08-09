module Platform
  class JourneySyncRequestProcessor
    attr_accessor :journeyBasket

    def initialize(basket)
      self.journeyBasket = basket
    end

    def getArguments
      []
    end

    def onResponse(response)
      nameids = []
      if response && response.childNodes
        for tag in response.childNodes do
          if "r" == tag.name.downcase
            nameids << Api::NameId.new(tag.text.split(","));
          elsif "j" == tag.name.downcase
            nameids << Api::NameId.new(tag.text.split(","));
          end
        end
      end
      journeyBasket.sync(nameids, nil, nil )
    end
  end
end