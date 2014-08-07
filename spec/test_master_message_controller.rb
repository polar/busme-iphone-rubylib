class TestMasterMessageController < Platform::MasterMessageController
  attr_accessor :test_displayed_master_message
  def presentMasterMessage(msg)
    @test_displayed_master_message = msg
  end

  def dismissCurrentMasterMessage(remind, time)
    super
    @test_displayed_master_message = nil
  end
end