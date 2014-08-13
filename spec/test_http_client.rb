
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
  attr_accessor :url
  attr_accessor :params

  def get(url)
    self.url = url
    mock_answer
  end
  def post(url, params)
    self.url = url
    self.params = params
    mock_answer
  end

end