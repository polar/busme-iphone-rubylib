require "spec_helper"
require "test_master_message_controller"

describe Platform::MasterMessageRequestProcessor do

  let(:time_now) { Time.now }
  let(:controller) { TestMasterMessageController.new }
  let(:store) { Platform::MasterMessageStore.new }
  let(:basket) { Platform::MasterMessageBasket.new(nil, store, controller) }
  let(:processor) { Platform::MasterMessageRequestProcessor.new(basket) }
  let(:msg1) {
    lit = "<Message id='1' version='1'><Content>Hello</Content></Message>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
    message = Api::MasterMessage.new
    message.loadParsedXML(tag)
    message
  }
  let(:msg2) {
    lit = "<Message id='2' version='1'><Content>Hello</Content></Message>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
    message = Api::MasterMessage.new
    message.loadParsedXML(tag)
    message
  }
  let(:response) {
    lit = "<Response><Messages>
            <Message id='1' destroy='1'/>
            <Message id='2' version='2'><Content>Goodbye</Content></Message>
            <Message id='3' version='1'><Content>Voila</Content></Message>
          </Messages></Response>"
    doc = REXML::Document.new(lit)
    tag = Api::Tag.new(doc.root)
  }

  it "should give the right arguments" do
    basket.addMasterMessage(msg1)
    basket.addMasterMessage(msg2)
    args = processor.getArguments
    expect(args.size).to eq(4)
    args1 = args.take(2)
    if !args1.include? ["message_ids[]", msg1.id]
      args2 = args1
      args1 = args.drop(2)
    else
      args2 = args.drop(2)
    end
    expect(args1).to include(["message_ids[]", msg1.id])
    expect(args1).to include(["message_versions[]", msg1.version.to_s])
    expect(args2).to include(["message_ids[]", msg2.id])
    expect(args2).to include(["message_versions[]", msg2.version.to_s])
  end

  it "should handle the response correctly" do
    basket.addMasterMessage(msg1)
    basket.addMasterMessage(msg2)
    processor.onResponse(response)
    expect(store.masterMessages[msg1.id]).to eq(nil)
    expect(store.masterMessages[msg2.id].version).to eq(2)
    expect(store.masterMessages["3"]).to_not eq(nil)
  end

end