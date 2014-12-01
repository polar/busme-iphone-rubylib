require "spec_helper"
require "test_platform_api"

class TestLoginEventForeground < Platform::LoginForeground
  attr_accessor :roleIntent
  attr_accessor :presented
  attr_accessor :dismissed

  def presentPasswordLogin(eventData)
    eventData.loginManager.login.email = "polar@syr.edu"
    eventData.loginManager.login.password = "NE1410s"
    if eventData.loginManager.login.roleIntent == "driver"
      eventData.loginManager.login.driverAuthCode = "12123"
    end
    self.presented = true
    super(eventData)
  end

  def presentRegistrationLogin(eventData)
    eventData.loginManager.login.email = "polar@syr.edu"
    eventData.loginManager.login.password = "NE1410s"
    eventData.loginManager.login.password_confirmation = "NE1410s"
    if eventData.loginManager.login.roleIntent == "driver"
      eventData.loginManager.login.driverAuthCode = "12123"
    end
    self.presented = true
    super(eventData)
  end

  def dismiss(eventData)
    self.dismissed = true
  end
end

class TestNetworkProblemController < Platform::FGNetworkProblemController
  attr_accessor :eventData
  def present(eventData)
    self.eventData = eventData
  end
end

describe Platform::LoginForeground do
  let (:time_now) {Utils::Time.current}
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:badResponse) { TestHttpMessage.new(500, "Internal Error", "")}
  let (:badResponse) { TestHttpMessage.new(500, "Internal Error", "")}
  let (:invalidToken) { TestHttpMessage.new(200, "OK", "<Login status='InvalidToken'/>'")}
  let (:invalidData) { TestHttpMessage.new(200, "OK", "<Login status='Invali'")}
  let (:InvalidPasswordConfirmation) { TestHttpMessage.new(200, "OK", "<Login status='InvalidPasswordConfirmation'/>'")}
  let (:InvalidPassword) { TestHttpMessage.new(200, "OK", "<Login status='InvalidPassword'/>'")}
  let (:notRegistered) { TestHttpMessage.new(200, "OK", "<Login status='NotRegistered'/>'")}
  let (:loginOK) { TestHttpMessage.new(200, "OK", "<login roleIntent='' email='polar@syr.edu' name='Dr Polar Humenn' roles='driver' authToken='testToken' status='OK'/>'")}
  let (:api) {
    api = TestPlatformApi.new
    api.mock_answer = suGet

    api.forceGet
    api
  }
  let (:login) { Api::Login.new }
  let (:loginManager) { Api::LoginManager.new(api, login)}
  let (:eventData) { Platform::LoginEventData.new(loginManager) }
  let (:loginForeground) { TestLoginEventForeground.new(api)}
  let (:loginBackground) { Platform::LoginBackground.new(api)}
  let (:networkProblemForeground) {TestNetworkProblemController.new(api)}

  before do
    loginForeground
    loginBackground
    networkProblemForeground
  end

  it "should login and dismiss" do
    # Banner Event has been set up with a banner's message to be displayed.
    login.loginState = Api::Login::LS_LOGIN
    login.loginTries = 0
    login.quiet = false
    api.uiEvents.postEvent("LoginEvent", eventData)
    api.uiEvents.roll()

    expect(login.email).to eq("polar@syr.edu")
    expect(login.password).to eq("NE1410s")
    expect(loginForeground.presented)

    api.mock_answer = loginOK
    api.bgEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGIN_SUCCESS)
    api.uiEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGGED_IN)
    expect(loginForeground.dismissed)

    expect(api.loginCredentials).to eq(login)
    expect(api.loggedIn?)
  end

  it "should stop after 3 times" do
    login.loginState = Api::Login::LS_LOGIN
    login.loginTries = 0
    login.quiet = false
    api.uiEvents.postEvent("LoginEvent", eventData)
    api.uiEvents.roll()
    tries = 0
    while (tries < Api::Login::LS_TRY_LIMIT) do
      expect(login.loginState).to eq(Api::Login::LS_LOGIN)

      loginForeground.presented = false

      api.mock_answer = invalidToken
      api.bgEvents.roll()
      expect(login.loginState).to eq(Api::Login::LS_LOGIN_FAILURE)
      # This will spawn a couple UI Events to allow for notifications of failures
      api.uiEvents.rollAll()
      tries += 1
    end
    expect(tries).to eq(Api::Login::LS_TRY_LIMIT)
    api.uiEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGGED_OUT)
    expect(loginForeground.dismissed)
  end

  it "should handle a network problem" do
    # Banner Event has been set up with a banner's message to be displayed.
    login.loginState = Api::Login::LS_LOGIN
    login.loginTries = 0
    login.quiet = false
    api.uiEvents.postEvent("LoginEvent", eventData)
    api.uiEvents.roll()
    expect(loginForeground.presented)

    api.mock_answer = IOError.new("Network unreachable")

    api.bgEvents.roll()
    expect(login.loginState).to eq(Api::Login::LS_LOGIN_FAILURE)
    api.uiEvents.rollAll()
    expect(login.loginState).to eq(Api::Login::LS_LOGIN)

    expect(networkProblemForeground.eventData.login).to eq(login)
  end

end