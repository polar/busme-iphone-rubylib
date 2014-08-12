class TestApi   < Api::BuspassAPI

  def initialize
    super("http://nothing", "android", "3.2.1")
    self.http_client.httpClient = TestHttpClient.new
  end

  def activeStartDisplayThreshold
    10
  end

  def getRouteDefinition(nameid)
    filename = File.join("spec", "test_data", "#{nameid.type}_#{nameid.name}_#{nameid.id}_#{nameid.version}.xml")
    file = File.new(filename)
    doc = REXML::Document.new(file)
    tag = Api::Tag.new(doc.root)
    route = Api::Route.new
    route.loadParsedXML(tag)
    route
  end

  def getJourneyPattern(id)
    filename = File.join("spec", "test_data", "P_#{id}.xml")
    file = File.new(filename)
    doc = REXML::Document.new(file)
    tag = Api::Tag.new(doc.root)
    pattern = Api::JourneyPattern.new
    pattern.loadParsedXML(tag)
    pattern
  end
end