require "spec_helper"
require "test_http_client"
require "test_api"

class TestListener
  include Api::BuspassEventListener
  attr_accessor :api
  def initialize(api)
    self.api = api
  end
  attr_accessor :event
  def onBuspassEvent(event)
    self.event = event
  end
end

class TestListener2 < TestListener
  def onBuspassEvent(event)
    super(event)
    api.loginManager.confirmLogin
  end
end


describe Api::LoginManager do
  let (:suGet) { fileName = File.join("spec", "test_data", "SUGet.xml"); TestHttpMessage.new(200, "OK", File.read(fileName))}
  let (:badResponse) { TestHttpMessage.new(500, "Internal Error", "")}
  let (:invalidToken) { TestHttpMessage.new(200, "OK", "<Login status='InvalidToken'/>'")}
  let (:invalidData) { TestHttpMessage.new(200, "OK", "<Login status='Invali'")}
  let (:InvalidPasswordConfirmation) { TestHttpMessage.new(200, "OK", "<Login status='InvalidPasswordConfirmation'/>'")}
  let (:InvalidPassword) { TestHttpMessage.new(200, "OK", "<Login status='InvalidPassword'/>'")}
  let (:notRegistered) { TestHttpMessage.new(200, "OK", "<Login status='NotRegistered'/>'")}
  let (:loginOK) { TestHttpMessage.new(200, "OK", "<login roleIntent='' email='polar@syr.edu' name='Dr Polar Humenn' roles='driver' authToken='testToken' status='OK'/>'")}
  let (:httpClient) { TestHttpClient.new }
  let (:api) {
    api = TestApi.new
    api.http_client.httpClient = httpClient
    httpClient.mock_answer = suGet

    api.forceGet
    api
  }
  let (:listener) { TestListener.new(api) }
  let (:login) { Api::Login.new }

  before do
    api.uiEvents.registerForEvent("LoginEvent", listener)
  end

  it "should handle get" do
    expect(api.buspass).to_not eq(nil)
    expect(api.buspass.loginUrl).to_not eq(nil)
    expect(api.buspass.authUrl).to_not eq(nil)
    expect(api.buspass.registerUrl).to_not eq(nil)
  end

  it "should handle the logins with the correct Urls" do
    login.loginState = Api::Login::LS_LOGIN
    api.bgEvents.triggerEvent("LoginEvent", login)

    # make sure we got the right URL
    expect(login.url).to eq(api.buspass.loginUrl)
    login.loginState = Api::Login::LS_AUTHTOKEN
    api.bgEvents.triggerEvent("LoginEvent", login)

    # make sure we got the right URL
    expect(login.url).to eq(api.buspass.authUrl)
    login.loginState = Api::Login::LS_REGISTER
    api.bgEvents.triggerEvent("LoginEvent", login)

    # make sure we got the right URL
    expect(login.url).to eq(api.buspass.registerUrl)
  end

  it "should hit the uiEvents" do

    login.loginState = Api::Login::LS_LOGIN
    api.bgEvents.triggerEvent("LoginEvent", login)
    api.uiEvents.roll

    expect(listener.event).to_not eq(nil)
    expect(listener.event.eventData).to eq(login)
  end

  def test_response(startState, response)
    login.email = "polar@syr.edu"
    login.loginState = startState

    httpClient.mock_answer = response

    api.bgEvents.triggerEvent("LoginEvent", login)
    api.uiEvents.roll
    login
  end

  it "should handle bad response from login, auth, and register" do
    test_response(Api::Login::LS_LOGIN, badResponse)
    expect(login.loginState).to eq(Api::Login::LS_LOGIN_FAILURE)
    test_response(Api::Login::LS_AUTHTOKEN, badResponse)
    expect(login.loginState).to eq(Api::Login::LS_AUTHTOKEN_FAILURE)
    test_response(Api::Login::LS_REGISTER, badResponse)
    expect(login.loginState).to eq(Api::Login::LS_REGISTER_FAILURE)
  end

  it "should handle badly parsed data" do
    test_response(Api::Login::LS_LOGIN, invalidData)
    expect(login.loginState).to eq(Api::Login::LS_LOGIN_FAILURE)
    test_response(Api::Login::LS_AUTHTOKEN, invalidData)
    expect(login.loginState).to eq(Api::Login::LS_AUTHTOKEN_FAILURE)
    test_response(Api::Login::LS_REGISTER, invalidData)
    expect(login.loginState).to eq(Api::Login::LS_REGISTER_FAILURE)
  end

  it "should handle failed logins" do
    test_response(Api::Login::LS_LOGIN, invalidToken)
    expect(login.loginState).to eq(Api::Login::LS_LOGIN_FAILURE)
    test_response(Api::Login::LS_AUTHTOKEN, invalidToken)
    expect(login.loginState).to eq(Api::Login::LS_AUTHTOKEN_FAILURE)
    test_response(Api::Login::LS_REGISTER, invalidToken)
    expect(login.loginState).to eq(Api::Login::LS_REGISTER_FAILURE)
  end

  it "should handle successful login" do
    test_response(Api::Login::LS_LOGIN, loginOK)
    expect(login.loginState).to eq(Api::Login::LS_LOGIN_SUCCESS)
    expect(login.email).to eq("polar@syr.edu")
    expect(login.name).to eq("Dr Polar Humenn")
    expect(login.roles).to include("driver")
    expect(login.authToken).to eq("testToken")
  end

  it "should handle successful auth" do
    test_response(Api::Login::LS_AUTHTOKEN, loginOK)
    expect(login.loginState).to eq(Api::Login::LS_AUTHTOKEN_SUCCESS)
    expect(login.email).to eq("polar@syr.edu")
    expect(login.name).to eq("Dr Polar Humenn")
    expect(login.roles).to include("driver")
    expect(login.authToken).to eq("testToken")
  end

  it "should handle successful register" do
    test_response(Api::Login::LS_REGISTER, loginOK)
    expect(login.loginState).to eq(Api::Login::LS_REGISTER_SUCCESS)
    expect(login.email).to eq("polar@syr.edu")
    expect(login.name).to eq("Dr Polar Humenn")
    expect(login.roles).to include("driver")
    expect(login.authToken).to eq("testToken")
  end

  it "should roll to logged in" do
    test_response(Api::Login::LS_LOGIN, loginOK)
    api.uiEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGGED_IN)
    test_response(Api::Login::LS_AUTHTOKEN, loginOK)
    api.uiEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGGED_IN)
    test_response(Api::Login::LS_REGISTER, loginOK)
    api.uiEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGGED_IN)
  end

  it "should roll to register from login and being not registered" do
    test_response(Api::Login::LS_LOGIN, notRegistered)
    api.uiEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_REGISTER)
  end

  it "should roll to password login on invalid token when not quiet" do
    login.quiet = false
    test_response(Api::Login::LS_AUTHTOKEN, invalidToken)
    api.uiEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGIN)
  end

  it "should roll to logged out on invalid token when quiet" do
    api.uiEvents.registerForEvent("LoginEvent", TestListener2.new(api))
    login.quiet = true
    test_response(Api::Login::LS_AUTHTOKEN, invalidToken)
    api.uiEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGGED_OUT)
  end


end