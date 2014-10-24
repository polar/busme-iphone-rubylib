module Api

  module Encoding

    def initWithCoderPrivate(decoder)
      id = decoder["_imid_"]
      #puts "Retrieving #{id} #{self.class} #{self.propList}"
      x  = decoder.id_map.retrieve(id)
      if x.nil?
        x = self
        decoder.id_map.store(x, id)
      end
      if decoder.bool("__imr__")
        if x.respond_to?(:propList)
          x.propList.each do |name|
            begin
              val = decoder[name]
              #puts "   #{name} = #{val.inspect}"
              x.instance_variable_set(name, val)
            rescue Exception => boom
              puts "On #{name} : #{boom}"
            end
          end
        end
        if x.respond_to? :initWithCoder
          x = x.initWithCoder(decoder)
        end
      end
      x
    end

    def initWithCoder2(decoder)
      id = decoder["_imid_"]
      #puts "Retrieving #{id} #{self.class} #{self.propList}"
      x  = IdentityMap.retrieve(id)
      if x.nil?
        x = self
        IdentityMap.store(x, id)
      end
      if decoder.bool("__imr__")
        x.propList.each do |name|
          begin
            val = decoder[name]
            #puts "   #{name} = #{val.inspect}"
            x.instance_variable_set(name, val)
          rescue Exception => boom
            puts "On #{name} : #{boom}"
          end
        end
      end
      x
    end

    def encodeWithCoderPrivate(encoder)
      id = "#{self.class.name}:#{self.__id__}"
      if encoder.id_map.retrieve(id)
        encoder["_imid_"] = id
        encoder.setBool("__imr__", false)
        # puts "Storing #{id} for retrieval"
      else
        encoder.id_map.store(self, id)
        encoder["_imid_"] = id
        encoder.setBool("__imr__", true)
        #puts "Storing #{id} ==> #{self.propList}"
        if self.respond_to? :propList
          self.propList.each do |x|
            val        = self.instance_variable_get(x)
            #puts " ==>  #{x} = #{val.inspect}"
            encoder[x] = val
          end
        end
        if self.respond_to? :encodeWithCoder
          self.encoderWithCoder(encoder)
        end
      end
    end

    def encodeWithCoder2(encoder)
      id = "#{self.class.name}:#{self.__id__}"
      if IdentityMap.retrieve(id)
        encoder["_imid_"] = id
        encoder.setBool("__imr__", false)
        # puts "Storing #{id} for retrieval"
      else
        IdentityMap.store(self, id)
        encoder["_imid_"] = id
        encoder.setBool("__imr__", true)
        #puts "Storing #{id} ==> #{self.propList}"
        self.propList.each do |x|
          val        = self.instance_variable_get(x)
          #puts " ==>  #{x} = #{val.inspect}"
          encoder[x] = val
        end
      end
    end
  end


  class Archiver

    class IdentityMap
      def initialize
        @classmap = {}
      end

      def clear
        @classmap = {}
      end

      def store(x, id)
        @classmap[id] = x
      end

      def retrieve(id)
        @classmap[id]
      end

      def keys
        @classmap.keys
      end
    end

    def self.xmlParse(data)
      doc = REXML::Document.new(data)
      Api::Tag.new(doc.root)
    end

    def self.encode(val, io = nil)
      res = encodeWithCoder(val, Coder.new(:io => io))
    end

    def self.decodeTag(tag, io = nil)
      decodeWithCoder(tag, Coder.new(:io => io))
    end

    def self.decode(data)
      decodeWithCoder(xmlParse(data), Coder.new)
    end

    def self.encodeWithCoder(val, coder)
      case val.class.name
        when "Fixnum", "String", "Boolean", "TrueClass", "FalseClass", "Hash", "Array", "Float", "Bignum"
          coder.encodeContent(val)

        else
          s = coder.io || StringIO.new("")
          s.write "<Object class='#{val.class.name}' id='#{val.__id__}'>"
          Coder.new(:io => coder.io, :id_map => coder.id_map).tap do |coder|
            if val.respond_to? :encodeWithCoderPrivate
              val.encodeWithCoderPrivate(coder)
              coder.hash.each do |k, v|
                s.write "<Item key='#{k}'>#{v}</Item>"
              end if coder.io.nil?
            end
          end
          s.write "</Object>"
          s.string if coder.io.nil?
      end
    end

    def self.decodeWithCoderKeys(object, tag, coder)
      hash = {}
      tag.childNodes.each do |node|
        hash[node.attributes["key"]] = node.childNodes.first
      end
      if object.respond_to? :initWithCoderPrivate
        object.initWithCoderPrivate(Coder.new(hash: hash, id_map: coder.id_map))
      else
        object
      end
    end

    def self.decodeWithCoder(tag, coder)
      return nil if tag.nil?
      case tag.name
        when "Boolean"
          tag.text == "true"
        when "Number"
          tag.text.to_f
        when "String"
          tag.text
        when "Hash"
          hash = {}
          tag.childNodes.each do |item|
            key           = item.childNodes.first
            key_val       = self.decodeWithCoder(key.childNodes.first, coder)
            val           = item.childNodes.drop(1).first
            val_val       = self.decodeWithCoder(val.childNodes.first, coder)
            hash[key_val] = val_val
          end
          hash
        when "Array"
          array = []
          tag.childNodes.each do |item|
            array << decodeWithCoder(item.childNodes.first, coder)
          end
          array
        when "Object"
          className = tag.attributes["class"]
          klass     = className.split("::").inject(Object) { |o, c| o.const_get c }
          obj       = klass.new
          if obj.respond_to? :initWithCoderPrivate
            Archiver.decodeWithCoderKeys(obj, tag, coder)
          else
            obj
          end
      end
    end

    class Coder
      attr_accessor :io
      attr_accessor :hash
      attr_accessor :id_map

      def initialize(args = {})
        self.hash   = args[:hash] || {}
        self.io     = args[:io]
        self.id_map = args[:id_map] || IdentityMap.new
      end

      def decodeObjectForKey(key)
        Archiver.decodeWithCoder(hash[key], self)
      end

      def encodeObjectForKey(value, key)
        s = io || StringIO.new("")
        s.write "<Item key='#{key}'>"
        s.write (x = encodeContent(value))
        s.write "</Item>"
        hash[key] = x if io.nil?
        s.string if io.nil?
      end

      def encodeContent(value)
        s = io || StringIO.new("")
        x = case value.class.name
              when "String", "NSString"
                "<String>#{value}</String>".tap do |x|
                  s.write x
                end
                s
              when "Array", "NSArray"
                s.write "<Array>"
                value.each_with_index do |val, index|
                  s.write "<Item index='#{index}'>"
                  s.write Archiver.encodeWithCoder(val, self)
                  s.write "</Item>"
                end
                s.write "</Array>"
                s
              when "Hash"
                s.write "<Hash>"
                value.each do |key, val|
                  s.write "<HashItem>"
                  s.write "<Key>"
                  s.write Archiver.encodeWithCoder(key, self)
                  s.write "</Key><Value>"
                  s.write Archiver.encodeWithCoder(val, self)
                  s.write "</Value></HashItem>"
                end
                s.write "</Hash>"
                s
              when "Fixnum", "Number", "Float", "Bignum"
                "<Number>#{value}</Number>".tap do |x|
                  s.write x
                end
                s
              when "Boolean", "TrueClass", "FalseClass"
                "<Boolean>#{value.to_s == "true"}</Boolean>".tap do |x|
                  s.write x
                end
                s
              when "NilClass"
                s
              else
                Archiver.encodeWithCoder(value, self).tap do |x|
                  s.write x
                end
                s
            end
        x.string if io.nil?
      end

      def [] key
        return self.decodeObjectForKey(key)
      end

      def []= key, value
        return self.encodeObjectForKey(value, key)
      end

      def bool(key)
        return self.decodeObjectForKey(key).to_s == "true"
      end

      def double(key)
        return self.decodeObjectForKey(key).to_f
      end

      def float(key)
        return self.decodeObjectForKey(key).to_f
      end

      def int(key)
        return self.decodeObjectForKey(key).to_i
      end

      def setBool(key, val)
        self.encodeObjectForKey(val.to_s == "true", key)
        return self
      end

      def setDouble(key, value)
        self.encodeObjectForKey(value.to_f, key)
        return self
      end

      def setFloat(key, value)
        self.encodeObjectForKey(value.to_f, key)
        return self
      end

      def setInt(key, value)
        self.encodeObjectForKey(value.to_i, key)
        return self
      end

    end
  end
end