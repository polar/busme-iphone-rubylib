module Utils
  #
  # Priority Queue
  #   Pops off "highest" element. All elements must really be of same type.
  #
  class PriorityQueue

    def initialize(elems = nil, &block)
      @queue = []
      @compare = block || lambda {|lhs,rhs| lhs <=> rhs }
      if elems
        elems.each {|x| push(x)}
      end
    end

    def include?(v)
      @queue.include?(v)
    end

    def push(v)
      upper = @queue.size - 1
      lower = 0
      while upper >= lower do
        idx = lower + (upper-lower)/2
        case @compare.call(v, @queue[idx])
          when 0, nil
            @queue.insert(idx, v)
            return v
          when 1, true
            lower = idx + 1
          when -1, false
            upper = idx -1
          else
            raise "bad comparator"
        end
      end if upper > -1
      @queue.insert(lower, v)
      return v
    end

    def poll
      @queue.slice!(@queue.size-1,1)[0] if @queue.size > 0
    end

    alias_method :pop, :poll

    def peek
      @queue.last
    end

    def delete(v)
      @queue.delete(v)
    end

  end
end