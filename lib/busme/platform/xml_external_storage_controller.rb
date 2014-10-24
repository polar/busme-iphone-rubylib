module Platform
  class XMLExternalStorageController < ExternalStorageController
      def serializeObjectToFile(store, filename)
        if isAvailable?
          if isWriteable?
            FileUtils.mkdir_p(directory)
            fn = File.join(directory, legalize(filename))
            file = File.open(fn, "w+")
            data = Api::Archiver.encode(store, file)
            file.close
            #writeFile(data, fn)
            true
          end
        end
      end

      def deserializeObjectFromFile(filename)
        if isAvailable?
          fn = File.join(directory, legalize(filename))
          store = Api::Archiver.decode(File.open(fn))
        end
      end
  end
end