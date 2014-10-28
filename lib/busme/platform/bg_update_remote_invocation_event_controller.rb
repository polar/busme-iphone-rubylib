module Platform

  class UpdateProgressEventData
    attr_accessor :controller
    attr_accessor :action
    attr_accessor :data
  end

  class UpdateProgressListener
    include Api::InvocationProgressListener
    attr_accessor :masterController

    def initialize(args)
      self.masterController = args[:masterController]
    end

    def onUpdateStart(time, isForced)
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_START
      evd.data = {time: time, isForced: isForced}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end
    def onArgumentsStart()
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_ARG_START
      evd.data = {}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end
    def onArgumentsFinish(makeRequest)
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_ARG_FIN
      evd.data = {makeRequest: makeRequest}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end
    def onRequestStart(time)
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_REQ_START
      evd.data = {time: time}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end
    def onRequestIOError(io_exception)
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_REQ_IOERROR
      evd.data = {ioException: io_exception}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end
    def onRequestFinish(time)
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_REQ_FIN
      evd.data = {time: time}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end
    def onResponseStart()
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_RESP_START
      evd.data = {}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end
    def onResponseFinish()
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_RESP_FIN
      evd.data = {}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end
    def onUpdateFinish(makeRequest, time)
      evd = UpdateProgressEventData.new
      evd.controller = masterController
      evd.action = U_FINISH
      evd.data = {makeRequest: makeRequest, time: time}
      masterController.api.uiEvents.postEvent("UpdateProgress", evd)
    end

  end

  class BG_UpdateRemoteInvocationEventController
    include Api::BuspassEventListener
    attr_accessor :api
    attr_accessor :enabled
    attr_accessor :updateRemoteInvocation
    attr_accessor :masterController
    attr_accessor :updateProgressListener

    def initialize(args)
      self.masterController = args[:masterController]
      self.api = args[:api] || masterController.api
      self.updateRemoteInvocation = args[:updateRemoteInvocation]
      self.updateProgressListener = args[:updateProgressListener] ||
          UpdateProgressListener.new(masterController: masterController)
      self.enabled = true
      api.bgEvents.registerForEvent("Update", self)
    end

    def onBuspassEvent(event)
      case event.eventName
        when "Update"
          eventData = event.eventData
          if eventData.pleaseStop
            self.enabled = false
            return
          end
          if enabled
            updateRemoteInvocation.invoke(
                eventData.syncProgressListener || self.updateProgressListener,
                eventData.isForced)
          end
      end
    end
  end
end