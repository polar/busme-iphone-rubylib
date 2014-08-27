module Platform
  class MarkerPresentEventData
    attr_accessor :marker_info

    def initialize(marker_info)
      self.marker_info = marker_info
    end
  end
end