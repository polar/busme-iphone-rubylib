module Platform
  class MarkerBasket
    attr_accessor :markerStore
    attr_accessor :markerController
    attr_accessor :activityAPI

    def initialize(store, controller)
      self.markerStore = store
      self.markerController = controller
    end

    def getMarkers
      markerStore.markers.values
    end

    def resetMarkers
      markerStore.markers.values.each do |marker|
        marker.reset
      end
    end

    def addMarker(marker_info)
      puts "MarkerBasket addMarker #{marker_info.title}"
      marker = markerStore.getMarker(marker_info.id)
      if marker
        if marker.version.to_i < marker_info.version.to_i
          markerStore.removeMarker(marker_info.id)
          markerController.removeMarker(marker) if markerController
          markerStore.addMarker(marker_info)
        end
      else
        markerStore.addMarker(marker_info)
      end
    end

    def removeMarker(key)
      marker = markerStore.getMarker(key)
      markerStore.removeMarker(key) if marker
      markerController.removeMarker(marker) if marker && markerController
    end

    def onLocationUpdate(location, time = nil)
      puts "MarkerBasket :onLocationUpdate #{location.inspect} #{markerStore.markers.values.inspect}"
      time = Utils::Time.current if time.nil?
      point = location ? GeoCalc.toGeoPoint(location) : nil
      for marker in markerStore.markers.values do
        if marker.is_a? Api::MarkerInfo
          # There is no expiry time on a marker
          # The system will tell us to remove it.
          #if time <= marker.expiryTime && (!marker.seen || marker.remindTime && marker.remindTime <= time)
          if marker.shouldBeSeen?(time)
            if marker.point
              if marker.radius && marker.radius > 0
                dist = GeoCalc.getGeoDistance(point, marker.point)
                puts "MarkerBasket : distance #{dist} radius #{marker.radius}"
                if dist < marker.radius
                  markerController.addMarker(marker)
                else
                  markerController.removeMarker(marker)
                end
              else
                markerController.addMarker(marker)
              end
            end
          end
        end
      end
    end

  end
end