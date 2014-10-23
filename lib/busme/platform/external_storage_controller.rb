module Platform
  class ExternalStorageController
    attr_accessor :masterController
    attr_accessor :api
    attr_accessor :available
    attr_accessor :writeable
    attr_accessor :directory

    def initialize(args)
      self.masterController = args[:masterController]
      self.api = args[:api]
      self.available = true
      self.writeable = true
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

    def directory
      d = nil
      d = masterController.directory if masterController
      d || @directory || File.join("Android", "data", "com.adiron.busme", "cache")
    end

    def serializeObjectToFile(store, filename)
      if isAvailable?
        data = YAML::dump(store)
        puts data.inspect
        writeFile(data, filename)
      end
    end

    def deserializeObjectFromFile(filename)
      if isAvailable?
        data = readData(filename)
        if data
          puts data
          store = YAML::load(data)
          return store
        end
      end
    end

    def writeFile(data, fileName)
      if isAvailable?
        FileUtils.mkdir_p(directory)
        fn = File.join(directory, legalize(fileName))
        puts "ExternalStorageController: Writing to #{fn}"
        file = File.new(fn, "w+")
        file.write(data)
        file.close
        true
      else
        false
      end
    rescue Exception => boom
      puts "ExternalStorageController.writeData(#{fn} => #{boom}"
      false
    end

    def readData(fileName)
      if isAvailable?
        fn = File.join(directory, legalize(fileName))
        puts "ExternalStorageController: reading from #{fn}"
        file = File.open(fn, "r")
        file.read
      end
    rescue Exception => boom
      puts "ExternalStorageController.readData(#{fn} => #{boom}"
      nil
    end

  end
end