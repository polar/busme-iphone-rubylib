module Platform
  class ExternalStorageController
    attr_accessor :api
    attr_accessor :available
    attr_accessor :writeable
    attr_accessor :directory

    def initialize(api)
      self.api = api
      self.available = true
      self.writeable = true
      self.directory = File.join("Android", "data", "com.adiron.busme", "cache")
    end

    def legalize(fileName)
      fileName.gsub(" ", "_").gsub("/","-").gsub("*",".")
    end

    def isAvailable?
      available
    end

    def isWriteable?
      writeable
    end

    def writeFile(data, fileName)
      if isAvailable?
        FileUtils.mkdir_p(directory)
        fn = File.join(directory, legalize(fileName))
        file = File.new(fn, "w+")
        file.write(data)
        file.close
        true
      else
        false
      end
    end

    def readData(fileName)
      if isAvailable?
        fn = File.join(directory, legalize(fileName))
        file = File.open(fn, "r")
        file.read
      end
    rescue Exception => boom
      nil
    end

  end
end