require "spec_helper"

describe Api::BannerInfo, "Initialization" do
  it 'should not be seen initially' do
    banner = Api::BannerInfo.new
    expect !banner.seen
  end
end

describe Api::BannerInfo, "Seen" do
  let(:time_now) { Time.now }
  it 'should be seen when lastSeen is set' do
    now = time_now
    banner = Api::BannerInfo.new
    banner.lastSeen = now - 10
    banner.expiryTime = now + 10
    banner.frequency = 10
    banner.length = 10
    expect banner.seen
  end

  it 'should be display expired after the length of display is over' do
    now = time_now
    banner = Api::BannerInfo.new
    banner.expiryTime = now + 20
    banner.frequency = 10
    banner.length = 10
    banner.onDisplay(now)
    now += banner.length + 1
    expect(banner.isDisplayTimeExpired?(now)).to eq(true)
  end

  it 'should not be seen, and should be seen' do
    now = time_now
    banner = Api::BannerInfo.new
    banner.expiryTime = now + 10
    banner.frequency = 10
    banner.length = 10
    expect !banner.seen
    expect(banner.shouldBeSeen?(now)).to eq(true)
  end

  it 'should not be seen if the banner is expired, even if never displayed' do
    now = time_now
    banner = Api::BannerInfo.new
    banner.expiryTime = now + 10
    banner.frequency = 10
    banner.length = 10
    expect !banner.seen
    now = banner.expiryTime + 1
    expect(banner.shouldBeSeen?(now)).to eq(false)
  end

  it 'should be not seen yet after last seen before frequency' do
    now = time_now
    banner = Api::BannerInfo.new
    banner.expiryTime = now + 20
    banner.frequency = 10
    banner.length = 10

    banner.onDisplay(now)
    now += banner.length + 1
    banner.onDismiss(now)
    now += banner.frequency - 1
    expect(banner.shouldBeSeen?(now)).to eq(false)
  end

  it 'should be seen after last seen after frequency' do
    now = time_now
    banner = Api::BannerInfo.new
    banner.expiryTime = now + 30
    banner.frequency = 10
    banner.length = 10
    banner.onDisplay(now)
    now += banner.length + 1
    banner.onDismiss(now)
    now += banner.frequency + 1
    expect(banner.shouldBeSeen?(now)).to eq(true)
  end
end