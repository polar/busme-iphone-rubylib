module Utils
  class Stack < Array
    def push(a)
      self.insert(0,a)
    end
    def peek
      self[0]
    end
    def pop
      self.slice!(0,1)[0]
    end
  end
end