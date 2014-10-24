module Platform
  class XMLExternalStorageController < ExternalStorageController
      def serializeObjectToFile(store, filename)
        if isAvailable?
          if isWriteable?
            FileUtils.mkdir_p(directory)
            fn = File.join(directory, legalize(filename))
            data = Api::Archiver.encode(store, File.open(fn, "w+"))
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