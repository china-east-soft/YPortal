require 'test_helper'

class BlacklistTest < ActiveSupport::TestCase
  def setup
    @block = Blacklist.new(blocker_id: 1, blocked_id: 2)
  end

  test "should be valid" do
    assert @block.valid?
  end

  test "should require a blocker id" do
    @block.blocker_id = nil
    assert_not @block.valid?
  end

  test "should require a blocked id" do
    @block.blocked_id = nil
    assert_not @block.valid?
  end

end
