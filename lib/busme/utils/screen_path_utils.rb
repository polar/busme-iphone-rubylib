module Utils
  class ScreenPathUtils
    EarthRadius = 6378137
    MinLatitude = -85.05112878
    MaxLatitude = 85.05112878
    MinLongitude = -180
    MaxLongitude = 180

    DefaultTileSize = 256

    @@mTileSize = DefaultTileSize

    def self.mTileSize
      @@mTileSize
    end

    def self.mTileSize=(size)
      @@mTileSize = size
    end

    ##
    # Clips a number to the specified minimum and maximum values.
    # @param n
    #            The number to clip
    # @param minValue
    #            Minimum allowable value
    # @param maxValue
    #            Maximum allowable value
    # @return The clipped value.
    def self.clip(n, minValue, maxValue)
      [[n,minValue].max, maxValue].min
    end

    ##
    # Determines the map width and height (in pixels) at a specified level of detail.
    #
    # @param levelOfDetail
    #            Level of detail, from 1 (lowest detail) to 23 (highest detail)
    # @return The map width and height in pixels
    #
    def self.getMapSize(levelOfDetail)
      (mTileSize << levelOfDetail).to_i
    end

    ##
    # Determines the ground resolution (in meters per pixel) at a specified latitude and level of
    # detail.
    #
    # @param latitude
    #            Latitude (in degrees) at which to measure the ground resolution
    # @param levelOfDetail
    #            Level of detail, from 1 (lowest detail) to 23 (highest detail)
    # @return The ground resolution, in meters per pixel
    #
    def self.groundResolution(latitude, levelOfDetail)
      latitude = clip(latitude, MinLatitude, MaxLatitude)
      return Math.cos(latitude * Math.PI / 180) * 2 * Math.PI * EarthRadius / getMapSize(levelOfDetail)
    end

    ##
    # Determines the map scale at a specified latitude, level of detail, and screen resolution.
    #
    # @param latitude
    #            Latitude (in degrees) at which to measure the map scale
    # @param levelOfDetail
    #            Level of detail, from 1 (lowest detail) to 23 (highest detail)
    # @param screenDpi
    #            Resolution of the screen, in dots per inch
    # @return The map scale, expressed as the denominator N of the ratio 1 : N
    #/
    def self.getMapScale(latitude, levelOfDetail, screenDpi)
		  return groundResolution(latitude, levelOfDetail) * screenDpi / 0.0254
    end

    ##
	  # Converts a point from latitude/longitude WGS-84 coordinates (in degrees) into pixel XY
    # coordinates at a specified level of detail.
    #
    # @param latitude
    #            Latitude of the point, in degrees
    # @param longitude
    #            Longitude of the point, in degrees
    # @param levelOfDetail
    #            Level of detail, from 1 (lowest detail) to 23 (highest detail)
    # @param reuse
    #            An optional Point to be recycled, or null to create a new one automatically
    # @return Output parameter receiving the X and Y coordinates in pixels
    #/
    def self.latLongToPixelXY(latitude, longitude, levelOfDetail, reuse = nil)
      out = reuse.nil? ? Integration::Point.new : reuse

      latitude = clip(latitude, MinLatitude, MaxLatitude)
      longitude = clip(longitude, MinLongitude, MaxLongitude)

      x = (longitude + 180) / 360
      sinLatitude = Math.sin(latitude * Math::PI / 180)
      y = 0.5 - Math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * Math::PI)

      mapSize = getMapSize(levelOfDetail)
      out.x = clip(x * mapSize + 0.5, 0, mapSize - 1)
      out.y = clip(y * mapSize + 0.5, 0, mapSize - 1)
      return out
    end

    ##
    # Converts a pixel from pixel XY coordinates at a specified level of detail into
    # latitude/longitude WGS-84 coordinates (in degrees).
    #
    # @param pixelX
    #            X coordinate of the point, in pixels
    # @param pixelY
    #            Y coordinate of the point, in pixels
    # @param levelOfDetail
    #            Level of detail, from 1 (lowest detail) to 23 (highest detail)
    # @param reuse
    #            An optional GeoPoint to be recycled, or null to create a new one automatically
    # @return Output parameter receiving the latitude and longitude in degrees.
    #/

    def self.pixelXYToLatLong(pixelX, pixelY, levelOfDetail, reuse = nil)
        out = reuse.nil? ? Integration::GeoPoint.new(0, 0) : reuse

        mapSize = getMapSize(levelOfDetail)
        x = (clip(pixelX, 0, mapSize - 1) / mapSize) - 0.5
        y = 0.5 - (clip(pixelY, 0, mapSize - 1) / mapSize)

        latitude = 90 - 360 * Math.atan(Math.exp(-y * 2 * Math.PI)) / Math.PI
        longitude = 360 * x

        out.latitudeE6 = latitude * 1E6
        out.longitudeE6 = longitude * 1E6
        return out
    end

    def self.toScreenPath(geoPoints, zoomLevel = Projection::MAX_ZOOM_LEVEL)
      thePath = []
      if geoPoints.length > 0
        thePath << latLongToPixelXY(geoPoints[0].latitude, geoPoints[0].longitude, zoomLevel)
      end

      for point in geoPoints do
        thePath << latLongToPixelXY(point.latitude, point.longitude, zoomLevel) if point
      end
      thePath
    end

    ##
    # This method returns a projected Path at the highest zoom level, which may be reduced to another
    # zoom level later by a particular progression. It also remove any duplicates, but at the
    # highest level we are only removing really close GeoPoints.
    #
    def self.toProjectedPath(geoPoints)
      toReducedScreenPath(geoPoints)
    end

    #
    # Converts a path of GeoPoints to screen coordinates at the current projection (zoomLevel)
    # It eliminates any duplicates. Typically what is done, is they are calculated at the
    # Maximum ZoomLevel 22, and then they are simply shifted for other zoom levels.
    #
    def self.toReducedScreenPath(geoPoints, zoomLevel = Projection::MAX_ZOOM_LEVEL)
      thePath = []
      lastPoint = nil
      if geoPoints.length > 0
        newPoint = latLongToPixelXY(geoPoints[0].latitude, geoPoints[0].longitude, zoomLevel)
        lastPoint = newPoint
        thePath << newPoint
      end
      for geoPoint in geoPoints
        if geoPoint
          newPoint = latLongToPixelXY(geoPoint.latitude, geoPoint.longitude, zoomLevel)
          if newPoint.x != lastPoint.x || newPoint.y != lastPoint.y
            thePath << newPoint
            lastPoint = newPoint
          end
        end
      end
      thePath
    end

    def self.toTranslatedPath(projectedPath, projection)
      path = []
      if projectedPath.length > 0
        last = projection.translatePoint(projectedPath.first)
        path << Integration::Point.new(last.x, last.y)
      end
      coords = Integration::Point.new
      for point in projectedPath
        projection.translatePoint(point, coords)
        if last.x != coords.x || last.y != coords.y
          path << Integration::Point.new(coords.x, coords.y)
        end
        last.set(coords.x, coords.y)
      end
      path
    end

    class Projection
      MAX_ZOOM_LEVEL = 22
      attr_accessor :zoomLevel
      attr_accessor :worldSize_2
      attr_accessor :offsetX
      attr_accessor :offsetY
      attr_accessor :screenRect

      def initialize(zoom, rect)
        self.zoomLevel = zoom
        self.screenRect = rect
        self.worldSize_2 = Utils::ScreenPathUtils.getMapSize(zoom)
        self.offsetX = self.offsetY = - worldSize_2
      end

      ##
		  # Performs the second computationally light part of the projection. Returns results in
	 	  # <I>screen coordinates</I>.
      #
      # @param in
      #            the Point calculated by the toMapPixelsProjected
      # @param reuse
      #            just pass null if you do not have a Point to be 'recycled'.
      # @return the Point containing the <I>Screen coordinates</I> of the initial GeoPoint passed
		  #         to the toMapPixelsProjected.
		  #
      def translatePoint(point, reuse = nil)
        out = reuse.nil? ? Integration::Point.new : reuse

        zoomDifference = MAX_ZOOM_LEVEL - zoomLevel
        out.x = (point.x >> zoomDifference) + offsetX
        out.y = (point.y >> zoomDifference) + offsetY
        out
      end

      def fromPixels(x, y)
        Utils::ScreenPathUtils.pixelXYToLatLong(screenRect.left + x + worldSize_2,
                            screenRect.top + y + worldSize_2, zoomLevel)
      end

      def toMapPixels(geoPoint, reuse = nil)
        out = reuse.nil? ? Integration::Point.new : reuse
        Utils::ScreenPathUtils.latLongToPixelXY(geoPoint.latitude, geoPoint.longitude, zoomLevel, out)
        out.offset(offsetX, offsetY)
        out
      end
    end

    def self.toClippedScreenPath(projectedPath, projection)
      rect = projection.screenRect
      path = Integration::Path.new
      if projectedPath.length > 0
        last = projection.translatePoint(projectedPath[0])
        onscreen = rect.containsXY(last.x, last.y)
        if ! onscreen
          path.moveTo(last.x, last.y)
        end
      end
      coords = Integration::Point.new
      for point in projectedPath
        projection.translatePoint(point, coords)
        if last.x != coords.x || last.y != coords.y
          if rect.containsXY(coords.x, coords.y)
            # if we were offscreen, we start a new segment from offscreen
            # to draw to onscreen, which will be clipped.
            if ! onscreen
              path.moveTo(last.x, last.y)
            end
            # Duplicates will be noticed and not added, but we never add dups anyway
            path.lineTo(coords.x, coords.y)
            onscreen = true
          else
            # If we were onscreen then we draw to off screen, which will be clipped.
            if onscreen
              path.lineTo(coords.x, coords.y)
            end
            onscreen = false
          end
        end
        last.set(coords.x, coords.y)
      end
      path
    end
  end
end