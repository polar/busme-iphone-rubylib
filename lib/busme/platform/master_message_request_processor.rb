module Platform
  class MasterMessageRequestProcessor
    attr_accessor :masterMessageBasket

    def initialize(basket)
      self.masterMessageBasket = basket
    end

    def getArguments
      if masterMessageBasket
        params = []
        for message in masterMessageBasket.getMasterMessages do
          params << ["message_ids[]", message.id]
          params << ["message_versions[]", "#{message.version}"]
        end
        params
      end
    end

    def onResponse(response)
      messages = {}
      if response && response.childNodes
        for tag in response.childNodes do
          if "messages" == tag.name.downcase
            for tag1 in  tag.childNodes do
              if "message" == tag1.name.downcase
                if tag1.attributes["destroy"]
                  messages[tag1.attributes["id"]] = nil
                else
                  message = Api::MasterMessage.new
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
          masterMessageBasket.removeMasterMessage(id)
        else
          masterMessageBasket.addMasterMessage(message)
        end
      end
    end
  end
end