module Platform
  class XMLExternalStorageController < ExternalStorageController
      def serializeObjectToFile(store, filename)
        if isAvailable?
          if isWriteable?
            FileUtils.mkdir_p(directory)
            fn = File.join(directory, legalize(filename))
            data = Api::Archiver.encode(store)
            writeFile(data, fn)
            true
          end
        end
      end

      def deserializeObjectFromFile(filename)
        if isAvailable?
          fn = File.join(directory, legalize(filename))
          data = readData(fn)
          if data
            store = Api::Archiver.decode(data)
            return store
          end
          nil
        end
      end
  end
end