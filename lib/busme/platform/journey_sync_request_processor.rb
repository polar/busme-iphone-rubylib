module Platform
  class JourneySyncRequestProcessor
    include Api::ArgumentPreparer
    include Api::ResponseProcessor

    attr_accessor :journeyController
    attr_accessor :progressListener

    def initialize(controller)
      self.journeyController = controller
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
      progressListener.onSyncEnd(nameids.length) if progressListener
      journeyController.sync(nameids, progressListener, progressListener)
    end
  end
end