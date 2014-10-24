module Api

  class IdentityMap
    @@classmap = {}
    def self.clear
      @@classmap = {}
    end
    def self.store(x, id)
      @@classmap[id] = x
    end

    def self.retrieve(id)
      @@classmap[id]
    end
    def self.keys
      @@classmap.keys
    end
  end

  module Encoding

    def initWithCoder(decoder)
      id = decoder["_imid_"]
      puts "Retrieving #{id} #{self.class} #{self.propList}"
      x = IdentityMap.retrieve(id)
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

    def encodeWithCoder(encoder)
      id = "#{self.class.name}:#{self.__id__}"
      if IdentityMap.retrieve(id)
        encoder["_imid_"] = id
        encoder.setBool("__imr__", false)
        puts "Storing #{id} for retrieval"
      else
        IdentityMap.store(self, id)
        encoder["_imid_"] = id
        encoder.setBool("__imr__", true)
        puts "Storing #{id} ==> #{self.propList}"
        self.propList.each do |x|
          val =  self.instance_variable_get(x)
          #puts " ==>  #{x} = #{val.inspect}"
          encoder[x] = val
        end
      end
    end
  end

  class Archiver

    def self.xmlParse(data)
      doc = REXML::Document.new(data)
      Api::Tag.new(doc.root)
    end

    def self.encode(val, io = nil)
      IdentityMap.clear
      res = encodeWithCoder(val, Coder.new(:io => io))
    end

    def self.decodeTag(tag, io = nil)
      IdentityMap.clear
      decodeWithCoder(tag, Coder.new(:io => io))
    end

    def self.decode(data)
      IdentityMap.clear
      decodeWithCoder(xmlParse(data), Coder.new)
    end

    def self.encodeWithCoder(val, coder)
      case val.class.name
        when "Fixnum", "String", "Boolean", "TrueClass", "FalseClass", "Hash", "Array", "Float", "Bignum"
          coder.encodeContent(val)

        else
          if val.respond_to? :encodeWithCoder
            s = coder.io || StringIO.new("")
            s.write "<Object class='#{val.class.name}' id='#{val.__id__}'>"
            Coder.new(:io => coder.io).tap do |coder|
              val.encodeWithCoder(coder)
              coder.hash.each do |k,v|
                s.write "<Item key='#{k}'>#{v}</Item>"
              end if coder.io.nil?
            end
            s.write "</Object>"
            s.string if coder.io.nil?
          else
            coder.encodeContent(value)
          end
      end
    end

    def self.decodeWithCoderKeys(object, tag, coder)
      hash = {}
      tag.childNodes.each do |node|
        hash[node.attributes["key"]] = node.childNodes.first
      end
      object.initWithCoder(Coder.new(hash: hash))
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
            key = item.childNodes.first
            key_val = self.decodeWithCoder(key.childNodes.first, self)
            val = item.childNodes.drop(1).first
            val_val = self.decodeWithCoder(val.childNodes.first, self)
            hash[key_val] = val_val
          end
          hash
        when "Array"
          array = []
          tag.childNodes.each do |item|
            array << decodeWithCoder(item.childNodes.first, self)
          end
          array
        when "Object"
          className = tag.attributes["class"]
          klass = className.split("::").inject(Object) {|o,c| o.const_get c}
          obj = klass.new
          if obj.respond_to? :initWithCoder
            Archiver.decodeWithCoderKeys(obj, tag, self)
          else
            obj
          end
      end
    end
  end

  class Coder
    attr_accessor :io
    attr_accessor :hash
    def initialize(args = {})
      self.hash = args[:hash] || {}
      self.io = args[:io]
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
          Archiver.encodeWithCoder(value, self)
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