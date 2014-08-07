class TestMasterMessageController < Platform::MasterMessageController
  attr_accessor :test_displayed_master_message
  def presentMasterMessage(msg)
    @test_displayed_master_message = msg
  end
end