require "spec_helper"
require "test_banner_controller"

describe Platform::BannerRequestProcessor do

  let(:time_now) { Utils::Time.current }
  let(:controller) { TestBannerController.new(nil) }
  let(:store) { Platform::BannerStore.new }
  let(:basket) { Platform::BannerBasket.new(store, controller) }
  let(:processor) { Platform::BannerRequestProcessor.new(basket) }
  let(:msg1) {
    lit = "<Banner id='1' version='1'><Content>Hello</Content></Banner>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
    message = Api::BannerInfo.new
    message.loadParsedXML(tag)
    message
  }
  let(:msg2) {
    lit = "<Banner id='2' version='9'><Content>Hello</Content></Banner>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
    message = Api::BannerInfo.new
    message.loadParsedXML(tag)
    message
  }
  let(:response) {
    lit = "<Response><Banners>
            <Banner id='1' destroy='1'/>
            <Banner id='2' version='10'><Content>Goodbye</Content></Banner>
            <Banner id='3' version='1'><Content>Voila</Content></Banner>
          </Banners></Response>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
  }

  it "should give the right arguments" do
    basket.addBanner(msg1)
    basket.addBanner(msg2)
    args = processor.getArguments
    # size is guaranteed, but order (other than (id,version) pairs coincide) is not
    expect(args.size).to eq(4)
    args1 = args.take(2)
    if !args1.include? ["banner_ids[]", msg1.id]
      # flip them so we can easily test
      args2 = args1
      args1 = args.drop(2)
    else
      args2 = args.drop(2)
    end
    expect(args1).to include(["banner_ids[]", msg1.id])
    expect(args1).to include(["banner_versions[]", msg1.version.to_s])
    expect(args2).to include(["banner_ids[]", msg2.id])
    expect(args2).to include(["banner_versions[]", msg2.version.to_s])
  end

  it "should handle the response correctly" do
    basket.addBanner(msg1)
    basket.addBanner(msg2)
    processor.onResponse(response)
    # should destroy banner1
    expect(store.banners[msg1.id]).to eq(nil)
    # should upgrade banner2
    expect(store.banners[msg2.id].version).to eq(10)
    # should now have banner 3
    expect(store.banners["3"]).to_not eq(nil)
  end

end