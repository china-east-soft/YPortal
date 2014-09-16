require 'test_helper'

class ProgramTest < ActiveSupport::TestCase
  test "channel should be uniq" do
    channel = "CMMB#12#34#杭州"
    p1 = Program.create(channel: channel, name: "cctv")

    p2 = Program.new(channel: channel, name: "cctv")
    p2.valid?
    assert_not_nil p2.errors[:channel]
  end
end
