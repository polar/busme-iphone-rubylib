class TestMarkerController < Platform::MarkerPresentationController
  attr_accessor :test_current_markers
  def initialize(api)
    super
    @test_current_markers = []
  end
  def presentMarker(msg)
    puts "presentMarker #{msg.inspect}"
    @test_current_markers << msg
  end

  def abandonMarker(marker)
    puts "abandonMarker #{marker.inspect}"
    @test_current_markers.delete(marker)
  end
end