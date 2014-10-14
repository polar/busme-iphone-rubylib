require "spec_helper"
require "test_http_client"
require "test_api"

class TestInvocation1
  include Api::ArgumentPreparer
  include Api::ResponseProcessor
  attr_accessor :tag

  def getArguments
    params = []
    params << ["arg1", "val1"]
    params
  end

  def onResponse(tag)
    self.tag = tag
  end
end

class TestInvocation2
  include Api::ArgumentPreparer
  include Api::ResponseProcessor
  attr_accessor :tag

  def getArguments
    params = []
    params << ["arg2", "val2"]
    params
  end

  def onResponse(tag)
    self.tag = tag
  end
end


describe Api::RemoteInvocation do
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml")
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:api) {
    api = TestApi.new
    api.mock_answer = suGet

    api.forceGet
    api
  }
  let (:testResponse) { TestHttpMessage.new(200, "OK", "<Example attr='3'/>'")}
  let(:invocation) { Api::RemoteInvocation.new(api, api.buspass.updateUrl) }
  let(:testInvocation1) { TestInvocation1.new }
  let(:testInvocation2) { TestInvocation2.new }

  # always instantiate the api first
  before do
    api
  end

  it "should make prepare arguments" do
    invocation.addArgumentPreparer(testInvocation1)
    invocation.invoke
    expect(api.http_client.httpClient.url).to eq(api.buspass.updateUrl)
    expect(api.http_client.httpClient.params).to include(["arg1", "val1"])
  end

  it "should make prepare arguments for multiple preparers" do
    invocation.addArgumentPreparer(testInvocation1)
    invocation.addArgumentPreparer(testInvocation2)
    invocation.invoke
    expect(api.http_client.httpClient.url).to eq(api.buspass.updateUrl)
    expect(api.http_client.httpClient.params).to include(["arg1", "val1"])
    expect(api.http_client.httpClient.params).to include(["arg2", "val2"])
  end

  it "should make process parsed result" do
    api.mock_answer = testResponse
    invocation.addArgumentPreparer(testInvocation1)
    invocation.addResponseProcessor(testInvocation1)
    invocation.invoke
    expect(api.http_client.httpClient.url).to eq(api.buspass.updateUrl)
    expect(api.http_client.httpClient.params).to include(["arg1", "val1"])
    expect(testInvocation1.tag.name).to eq("Example")
    expect(testInvocation1.tag.attributes["attr"]).to eq("3")
  end

  it "should make process parsed result on multiple repsonse processors" do
    api.mock_answer = testResponse
    invocation.addArgumentPreparer(testInvocation1)
    invocation.addResponseProcessor(testInvocation1)
    invocation.addResponseProcessor(testInvocation2)
    invocation.invoke
    expect(api.http_client.httpClient.url).to eq(api.buspass.updateUrl)
    expect(api.http_client.httpClient.params).to include(["arg1", "val1"])
    expect(testInvocation1.tag.name).to eq("Example")
    expect(testInvocation1.tag.attributes["attr"]).to eq("3")
    expect(testInvocation2.tag.name).to eq("Example")
    expect(testInvocation2.tag.attributes["attr"]).to eq("3")
  end
end