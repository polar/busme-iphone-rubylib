class TestBannerForeground < Platform::BannerForeground
  attr_accessor :test_url
  attr_accessor :test_state

  def presentBanner(eventData)
    # User has clicked, and now we are bringing up a window/browser, something.
    self.test_state = eventData.state
    eventData.state = Platform::BannerEventData::S_CLICK
    api.bgEvents.postEvent("BannerEvent", eventData)
  end

  def presentBannerClickThrough(eventData)
    # User has clicked, and now we are bringing up a window/browser, something.
    self.test_url = eventData.thruUrl
    self.test_state = eventData.state
  end

end