require "test_helper"

class AuthMessageTest < ActiveSupport::TestCase
  def setup
    @auth_message = AuthMessage.new mobile: "13738091353", category: 1
    @auth_message.save
  end

  test "should generate_verify_code" do
    assert_not_nil @auth_message.verify_code
  end

  test "send out should large than zero" do
    assert @auth_message.send_result > 0
  end

end
