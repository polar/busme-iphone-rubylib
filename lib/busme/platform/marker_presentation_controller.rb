module Platform
  class MarkerPresentationController
    attr_accessor :markerPresentLimit
    attr_accessor :currentMarkers
    attr_accessor :removeMarkers
    attr_accessor :api

    def initialize(api)
      self.api = api
      @markerQ = Utils::PriorityQueue.new {|lhs,rhs| compare(lhs,rhs)}
      self.currentMarkers = []
      self.removeMarkers = []
      self.markerPresentLimit = 10
    end

    # Background Thread

    def addMarker(marker)
      puts "MarkerPresentationController.addMarker #{marker.title}"
      replace = false
      found = false
      currentMarkers.dup.each do |m|
        if m.id == marker.id
          found = true
          if m.version.to_i < marker.version.to_i
            puts "Replace CurrentMarker #{m.inspect}"
            self.removeMarkers << m
            self.currentMarkers.delete(m)
            replace = true
          end
        end
      end
      @markerQ.elements.each do |m|
        if m.id == marker.id
          found = true
          if m.version.to_i < marker.version.to_i
            @markerQ.delete(m)
            replace = true
          end
        end
      end
      if replace || !found
        @markerQ.push(marker)
      end
    end

    def removeMarker(marker)
      self.removeMarkers << marker
    end

    def roll(now = nil)
      puts "MarkerPresentationController. roll remove #{removeMarkers.size} markers #{currentMarkers.size} limit #{markerPresentLimit}"
      now = Utils::Time.current  if now.nil?
      # We sort because we have present time calculations.
      removeMarkers.dup.each do |marker|
        puts "RemoveMarker: Looking at #{marker.inspect}"
        if marker.displayed
          marker.onDismiss(true, now)
          abandonMarker(marker)
        end
        removeMarkers.delete(marker)
      end
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
          # markers dont have expiryTimes
        elsif marker.expiryTime && marker.expiryTime <= now
          if marker.displayed
            marker.onDismiss(true, now)
            abandonMarker(marker)
          end
        else
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
      puts "Marker Presentation Controller presentMarker #{marker}"
      eventData = MarkerPresentEventData.new(marker)
      api.uiEvents.postEvent("MarkerPresent:Add", eventData)
    end

    def abandonMarker(marker)
      puts "Marker Presentation Controller abandonMarker #{marker}"
      eventData = MarkerPresentEventData.new(marker)
      api.uiEvents.postEvent("MarkerPresent:Remove", eventData)
    end
  end
end