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

    def size
      @queue.size
    end

    def any?(&block)
      @queue.any?(&block)
    end

    alias_method :length, :size

    def include?(v)
      @queue.include?(v)
    end

    def push(v)
      @queue << v
      return v
    end

    def copy
      raise "Copy Called"
    end

    def poll
      res = @queue.slice!(0)
      res
    rescue Exception => boom
      puts boom
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