require "spec_helper"

describe Api::BannerInfo, "Initialization" do
  it 'should not be seen initially' do
    @banner = Api::BannerInfo.new
    expect !@banner.seen
  end
end

describe Api::BannerInfo, "Seen" do
  it 'should be seen when lastSeen is set' do
    @banner = Api::BannerInfo.new
    @banner.lastSeen = Time.now - 10
    @banner.expiryTime = Time.now + 10
    @banner.frequency = 10
    @banner.length = 10
    expect @banner.seen
  end

  it 'should be display expired after the length of display is over' do
    @banner = Api::BannerInfo.new
    @banner.lastSeen = Time.now - 10
    @banner.expiryTime = Time.now + 10
    @banner.frequency = 10
    @banner.length = 10
    expect(@banner.isDisplayTimeExpired?(Time.now)).to eq(true)
  end

  it 'should not be seen, and should be seen' do
    @banner = Api::BannerInfo.new
    @banner.expiryTime = Time.now + 10
    @banner.frequency = 10
    @banner.length = 10
    expect !@banner.seen
    expect(@banner.shouldBeSeen?(Time.now)).to eq(true)
  end

  it 'should not be seen if the banner is expired, even if never displayed' do
    @banner = Api::BannerInfo.new
    @banner.expiryTime = Time.now - 10
    @banner.frequency = 10
    @banner.length = 10
    expect !@banner.seen
    expect(@banner.shouldBeSeen?(Time.now)).to eq(false)
  end

  it 'should be not seen yet after last seen before frequency' do
    @banner = Api::BannerInfo.new
    @banner.lastSeen = Time.now - 5
    @banner.expiryTime = Time.now + 10
    @banner.frequency = 10
    @banner.length = 10
    expect(@banner.shouldBeSeen?(Time.now)).to eq(false)
  end

  it 'should be seen yet after last seen after frequency' do
    @banner = Api::BannerInfo.new
    @banner.lastSeen = Time.now - 15
    @banner.expiryTime = Time.now + 10
    @banner.frequency = 10
    @banner.length = 10
    expect(@banner.shouldBeSeen?(Time.now)).to eq(true)
  end
end