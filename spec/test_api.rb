require "test_http_client"

class TestApi   < Api::BuspassAPI

  def initialize
    super(Testlib::MyHttpClient.new(TestHttpClient.new), "slug", "http://nothing", "android", "3.2.1")
  end

  def activeStartDisplayThreshold
    10 * 60 * 1000
  end

  def mock_answer=(x)
    http_client.mock_answer = x
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