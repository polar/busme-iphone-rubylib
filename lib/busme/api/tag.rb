module Api
  class Tag
    def initialize(element)
      @element = element
    end

    def name
      @element.name
    end

    def attributes
      @element.attributes
    end

    def childNodes
      @childNodes ||= @element.children.map {|x| Tag.new(x) if x.is_a? REXML::Element}.compact
    end

    def text
      @text ||= @element.text
    end
  end
end
