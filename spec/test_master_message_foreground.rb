class TestMasterMessageForeground < Platform::MasterMessageForeground
  attr_accessor :test_url
  attr_accessor :test_previous_state

  def onBuspassEvent(event)
    self.test_url            = event.eventData.thruUrl
    self.test_previous_state = event.eventData.state
    super(event)
  end
end