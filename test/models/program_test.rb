require 'test_helper'

class ProgramTest < ActiveSupport::TestCase
  test "channel should be uniq" do
    channel = "CMMB#12#34#杭州"
    p1 = Program.create(channel: channel, name: "cctv")

    p2 = Program.new(channel: channel, name: "cctv")
    p2.valid?
    assert_not_nil p2.errors[:channel]
  end

  test "comment count cache should increase" do
    p = create(:program)
    10.times do
      c = create(:comment)
      p.comments << c
    end

    p.reload
    assert_equal p.comments_count,  p.comments.count
  end

  test "comment count cache should decrease" do
    p = create(:program)
    10.times do
      c = create(:comment)
      p.comments << c
    end

    p = Program.find_by(channel: p.channel)
    p.comments.first.destroy
    p.reload

    assert_equal p.comments.count, 9
    assert_equal p.comments_count,  p.comments.count
  end

end
