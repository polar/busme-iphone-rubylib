require "spec_helper"

describe Api::BannerInfo, "Initialization" do
  it 'should not be seen initially' do
    banner = Api::BannerInfo.new
    expect !banner.seen
  end
end

describe Api::BannerInfo, "Seen" do
  let(:time_now) { Utils::Time.current }
  let(:banner_lit) {
    "
      <Banner id='1' version='121' lat='53.0' lon='-73.0' length='10'
              frequency='10000' priority='1' expiryTime='#{time_now.to_i}'
              radius='200'
              goUrl='http://busme.us'
              iconUrl='http://something.org/pic.png'
              ><Title>Title1</Title><Description>Hello</Description>
      </Banner>
      "
  }
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

  it "should parse valid banner correctly" do
    banner = Api::BannerInfo.new
    doc = REXML::Document.new(banner_lit)
    tag = Api::Tag.new(doc.root)
    banner.loadParsedXML(tag)
    expect(banner.id).to eq("1")
    expect(banner.version).to eq(121)
    expect(banner.frequency).to eq(10)
    expect(banner.priority).to eq(1)
    expect(banner.radius).to eq(200)
    expect(banner.goUrl).to eq('http://busme.us')
    expect(banner.iconUrl).to eq('http://something.org/pic.png')
    expect(banner.title).to eq("Title1")
    expect(banner.description).to eq("Hello")
    expect(Platform::GeoCalc.equalCoordinates(banner.point, Integration::GeoPoint.new(53.0*1E6, -73.0*1E6)))
  end
end