module Platform
  class MarkerPresentationController
    attr_accessor :markerPresentLimit
    attr_accessor :currentMarkers
    attr_accessor :api

    def initialize(api)
      self.api = api
      @markerQ = Utils::PriorityQueue.new {|lhs,rhs| compare(lhs,rhs)}
      self.currentMarkers = []
      self.markerPresentLimit = 10
    end

    # Background Thread

    def addMarker(marker)
      @markerQ.push(marker)
    end

    def removeMarker(marker)
      @markerQ.delete(marker)
    end

    def roll(now = nil)
      now = Utils::Time.current  if now.nil?
      # We sort because we have present time calculations.
      backOnQueue = []
      @markerQ.sort!
      self.currentMarkers.each {|x| @markerQ.push(x) }
      self.currentMarkers = []
      marker = @markerQ.poll
      while marker do
        if marker.shouldBeSeen?(now)
          if currentMarkers.size < markerPresentLimit
            if !marker.displayed
              self.currentMarkers << marker
              presentMarker(marker)
              marker.onDisplay(now)
            else
              self.currentMarkers << marker
            end
          else
            if marker.displayed
              marker.onDismiss(true, now)
              abandonMarker(marker)
            else
              backOnQueue << marker
            end
          end
        elsif marker.expiryTime <= now
          if marker.displayed
            marker.onDismiss(true, now)
            abandonMarker(marker)
          end
        end
        marker = @markerQ.poll
      end
      backOnQueue.each {|x| @markerQ.push(x) }
    end

    def dismissMarker(marker, remind, time = nil)
      time = Utils::Time.current if time.nil?
      if marker
        marker.onDismiss(remind, time)
        abandonMarker(marker)
      end
    end

    # Either Thread

    def contains?(marker)
      @markerQ.include?(marker) || currentMarkers.include?(marker)
    end

    def removeDisplayedMarker(marker)
      if marker && marker.displayed
        marker.onDismiss(false, Utils::Time.current)
        abandonMarker(marker)
      end
    end

    protected

    def compare(b1,b2)
      now = Utils::Time.current
      priority =  b1.priority <=> b2.priority
      if priority == 0
        b1.nextTime(now) <=> b2.nextTime(now)
      else
        priority
      end
    end

    def presentMarker(marker)
      eventData = MarkerPresentEventData.new(marker)
      api.uiEvents.postEvent("MarkerPresent:Add", eventData)
    end

    def abandonMarker(marker)
      eventData = MarkerPresentEventData.new(marker)
      api.uiEvents.postEvent("MarkerPresent:Remove", eventData)
    end
  end
end