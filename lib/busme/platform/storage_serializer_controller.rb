module Platform
  class StorageSerializerController
    attr_accessor :api
    attr_accessor :externalStorageController

    def initialize(api, externalStorageController)
      self.api = api
      self.externalStorageController = externalStorageController
    end

    def retrieveStorage(fileName, api)
      if externalStorageController.isAvailable?
        data = externalStorageController.readData(fileName)
        if data
          store = YAML::load(data)
          if store.is_a? Api::Storage
            store.postSerialize(api)
          end
          return store
        end
      end
    end

    def cacheStorage(store, filename, api)
      preserialized = false
      if externalStorageController.isAvailable?
        if externalStorageController.isWriteable?
          if store.is_a?(Api::Storage)
            store.preSerialize(api)
            preserialized = true
          end
          data = YAML::dump(store)
          externalStorageController.writeFile(data, filename)
        end
      end
    rescue Exception => boom

    ensure
      if preserialized && store.is_a?(Api::Storage)
        store.postSerialize(api)
      end
    end

  end
end