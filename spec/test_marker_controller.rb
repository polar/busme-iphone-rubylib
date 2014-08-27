class TestMarkerController < Platform::MarkerPresentationController
  attr_accessor :test_current_markers
  def initialize
    super
    @test_current_markers = []
  end
  def presentMarker(msg)
    @test_current_markers << msg
  end

  def abandonMarker(marker)
    @test_current_markers.delete(marker)
  end
end