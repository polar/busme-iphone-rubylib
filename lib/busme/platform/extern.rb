module Api
  class Extern
    def self.cache(x, filename)
      IdentityMap.clear
      data = Archiver.encode(x)
    rescue Exception => boom
      puts "Cache #{boom}"
    end

    def self.retrieve(filename)
      IdentityMap.clear
      obs = NSKeyedUnarchiver.unarchiveObjectWithFile(filename)
      obs
    rescue Exception => boom
      puts "Cache #{boom}"
      nil
    end
  end

end