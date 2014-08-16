module Utils
  #
  # Queue
  #
  class Queue

    def initialize(elems = nil)
      @queue = []
      if elems
        elems.each {|x| push(x)}
      end
    end

    def include?(v)
      @queue.include?(v)
    end

    def push(v)
      @queue << v
      return v
    end

    def poll
      @queue.slice!(0,1)[0]
    end

    alias_method :pop, :poll

    def peek
      @queue.first
    end

    def delete(v)
      @queue.delete(v)
    end

  end
end