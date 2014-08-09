module Platform
  class MarkerRequestProcessor
    attr_accessor :markerBasket

    def initialize(basket)
      self.markerBasket = basket
    end

    def getArguments
      if markerBasket
        params = []
        for marker in markerBasket.getMarkers do
          params << ["marker_ids[]", marker.id]
          params << ["marker_versions[]", "#{marker.version}"]
        end
        params
      end
    end

    def onResponse(response)
      markers = {}
      if response && response.childNodes
        for tag in response.childNodes do
          if "markers" == tag.name.downcase
            for tag1 in  tag.childNodes do
              if "marker" == tag1.name.downcase
                if tag1.attributes["destroy"]
                  markers[tag1.attributes["id"]] = nil
                else
                  marker = Api::MarkerInfo.new
                  marker.loadParsedXML(tag1)
                  markers[marker.id] = marker
                end
              end
            end
          end
        end
      end
      for id, marker in markers do
        if marker.nil?
          markerBasket.removeMarker(id)
        else
          markerBasket.addMarker(marker)
        end
      end
    end
  end
end