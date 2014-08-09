module Platform
  class MarkerBasket
    attr_accessor :markerStore
    attr_accessor :markerController
    attr_accessor :activityAPI

    def initialize(api, store, controller)
      self.activityAPI = api
      self.markerStore = store
      self.markerController = controller
    end

    def getMarkers
      markerStore.markers.values
    end

    def addMarker(marker_info)
      markerStore.addMarker(marker_info)
    end

    def removeMarker(key)
      markerStore.removeMarker(key)
    end

    def onLocationUpdate(location, time = nil)
      time = Time.now if time.nil?
      point = location ? GeoCalc.toGeoPoint(location) : nil
      for marker in markerStore.markers.values do
        if marker.is_a? Api::MarkerInfo
          if time <= marker.expiryTime && (!marker.seen || marker.remindTime && marker.remindTime <= time)
            if marker.point
              if marker.radius && marker.radius > 0
                dist = GeoCalc.getGeoDistance(point, marker.point)
                if dist < marker.radius
                  markerController.addMarker(marker)
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