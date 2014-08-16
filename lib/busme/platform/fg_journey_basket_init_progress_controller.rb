module Platform
  class FGJourneyBasketInitProgressController
    include JourneyBasket.ProgressListener

    attr_accessor :api
    attr_accessor :nRoutes

    def initialize(api)
      self.api = api
    end

    def onSyncStart

    end

    def onSyncEnd(nRoutes)
      self.nRoutes = nRoutes
    end

    def onRouteStart(iRoute)

    end

    def onRouteEnd(iRoute)

    end

    def onDone

    end

    def onIOError(error)

    end
  end
end