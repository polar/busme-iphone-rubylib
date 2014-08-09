class TestJourneyDisplayController < Platform::JourneyDisplayController
  attr_accessor :test_presented_journey_displays
  def initialize(*args)
    super
    self.test_presented_journey_displays = []
  end
  def presentJourneyDisplay(journey_display)
    @test_presented_journey_displays << journey_display
  end

  def abandonJourneyDisplay(journey_display)
    @test_presented_journey_displays.delete journey_display
  end
end