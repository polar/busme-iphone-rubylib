
class TestHttpHeader
  attr_accessor :status_code
  attr_accessor :reason_phrase
  attr_accessor :items
  def initialize(code, reason, headers = {})
    self.status_code = code
    self.reason_phrase = reason
    self.items = headers
  end
end
class TestHttpMessage
  attr_accessor :header
  attr_accessor :body
  class A
    attr_accessor :content
    def length
      content.length
    end
    def initialize(content)
      self.content = content
    end
  end
  def initialize(code, reason, body, headers = {})
    self.header = TestHttpHeader.new(code, reason, headers)
    self.body = A.new(body)
  end
end

class TestHttpClient
  # Should be a TestHttpMessage
  attr_accessor :mock_answer

  def get(url)
    mock_answer
  end
  def post(url, params)
    mock_answer
  end

end