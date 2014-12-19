module Integration
  class PathRetain < Path

    def initialize(npoints)
      @npoints = npoints
      @pathsCount = 0
      @counts = [0]
      @paths = [Array.new(@npoints) { |i| Point.new(0,0)}]
    end

    def pathsCount
      @pathsCount
    end

    def pathAt(index)
      @paths[index]
    end

    def onEach(&block)
      for i in 0..@pathsCount-1 do
        yield @paths[i], @counts[i]
      end
    end

    def paths
      result = []
      for i in 0..@pathsCount-1
        if @counts[i] == 0
          break
        else
          result << @paths[i]
        end
      end
    end

    def reset
      @pathsCount = 0
      for i in 0..@paths.size
        @counts[i] = 0
      end
    end

    def moveTo(x, y = nil)
      if x.is_a?(Point)
        y = x.y
        x = x.x
      end
      # Ensure we have an empty path to go to
      if @pathsCount >= @paths.size
        @paths << Array.new(@npoints) {|i| Point.new(0,0)}
        @counts[@pathsCount] = 0
      end
      @pathsCount += 1
      @counts[@pathsCount - 1] = 0 # This should be the case anyway
      addPoint(@pathsCount-1, x, y)
    end

    def lineTo(x, y = nil)
      if x.is_a?(Point)
        y = x.y
        x = x.x
      end
      path = @paths[@pathsCount-1]
      if path.nil?
        moveTo(x,y)
      else
        last = path[@counts[@pathsCount-1]]
        addPoint(@pathsCount-1, x, y) if last.nil? || x != last.x || y != last.y
      end
    end

    private

    def addPoint(index, x, y)
      # Ensure capacity of reusable points
      if @counts[index] >= @paths[index].size
        @paths[index] += Array.new(@npoints) {|i| Point.new(0,0)}
      end
      @paths[index][@counts[index]].set(x,y)
      @counts[index] += 1
    end
  end
end