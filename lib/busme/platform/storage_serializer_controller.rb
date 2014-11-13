module Platform
  class StorageSerializerController
    attr_accessor :api
    attr_accessor :externalStorageController

    def initialize(api, externalStorageController)
      self.api = api
      self.externalStorageController = externalStorageController
    end

    def retrieveStorage(filename, api)
      if externalStorageController.isAvailable?
       #puts "Trying to read #{filename}....."
        store = externalStorageController.deserializeObjectFromFile(filename)
        if store
          if store.is_a? Api::Storage
            store.postSerialize(api)
            return store
          else
            return nil
          end
        end
      end
    rescue Exception => boom
     #puts "retrieveStorage(#{filename}) => #{boom}"
      nil
    end

    def cacheStorage(store, filename, api)
      preserialized = false
      if externalStorageController.isAvailable?
        if externalStorageController.isWriteable?
          if store.is_a?(Api::Storage)
            store.preSerialize(api)
            preserialized = true
          end
          externalStorageController.serializeObjectToFile(store, filename)
        end
      end
    rescue Exception => boom
      puts "cacheStorage(#{filename}) => #{boom}"
    ensure
      if preserialized && store.is_a?(Api::Storage)
        store.postSerialize(api)
      end
    end

  end
end