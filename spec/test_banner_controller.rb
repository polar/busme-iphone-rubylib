class TestBannerController < Platform::BannerController
  attr_accessor :test_displayed_banner
  attr_accessor :test_removed_banner
  def presentBanner(banner)
    @test_displayed_banner = banner
  end

  def abandonBanner(banner)
    @test_displayed_banner = nil
    @test_removed_banner = banner
  end
end