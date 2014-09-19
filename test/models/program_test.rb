require 'test_helper'

class ProgramTest < ActiveSupport::TestCase
  test "channel with invalid format" do
    invalid_channel = "CMMB#12-34-杭州"
    p1 = Program.new(channel: invalid_channel, name: "cctv")
    p1.valid?
    assert_not_nil p1.errors[:channel]
  end

  test "channel with valid format" do
    valid_channel = "CMMB-12-34-杭州"
    p1 = Program.new(channel: valid_channel, name: "cctv")
    p1.valid?
    assert p1.save
  end


  test "channel should be uniq" do
    channel = "CMMB-12-34-杭州"
    p1 = Program.new(channel: channel, name: "cctv")
    assert p1.save

    p2 = Program.new(channel: channel, name: "cctv")
    p2.valid?
    assert_not_nil p2.errors[:channel]
  end

  test "should auto generate mode freq sid and location" do
    channel = "CMMB-12-34-杭州"
    p1 = Program.new(channel: channel, name: "cctv")
    p1.valid?
    assert_not_nil p1.mode
    assert p1.save
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

  test "find_or_create_by_channel should create program if not exist" do
    channel = "CMMB-22-44-杭州"

    assert_nil Program.find_by(channel: channel)

    assert_difference "Program.count" do
      Program.find_or_create_by_channel(channel)
    end
  end

  test "find_or_create_by_channel should find program if alrady exist" do
    p = create(:program)
    assert_not_nil p

    p_find = nil

    assert_no_difference "Program.count" do
      p_find = Program.find_or_create_by_channel(p.channel)
    end

    assert_equal p_find, p

  end

  test "find_or_create_by_channel create CMMB GLOBAL program" do
    channel = "CMMB-32-601-杭州"
    program = nil

    assert_difference "Program.count" do
      program = Program.find_or_create_by_channel(channel)
    end
    assert_equal program.channel, "CMMB-00-601-*"
  end

  test "find_or_create_by_channel should find CMMB GLOBAL program" do
    channel = "CMMB-00-601-*"
    p = Program.create(channel: channel, name: Program::CMMB_SID_GLOBAL_PROGRAMS["601"])
    assert_not_nil p

    channel = "CMMB-32-601-杭州"
    program = nil

    assert_no_difference "Program.count" do
      program = Program.find_or_create_by_channel(channel)
    end
    assert_equal program.channel, "CMMB-00-601-*"
    assert_equal program, p
  end

  test "find_by_channel should find program" do
    p = create(:program)

    program = nil
    assert_no_difference "Program.count" do
      program = Program.find_by_channel(p.channel)
    end
    assert_equal program, p
  end

  test "find_by_channel should not find program" do
    channel = "CMMB-12-34-杭州"
    program = nil

    assert_no_difference "Program.count" do
      program = Program.find_by_channel(channel)
    end
    assert_nil program
  end

  test "find_by_channel should find CMMB GLOBAL program" do

    channel = "CMMB-32-601-杭州"
    assert_no_difference "Program.count" do
      program = Program.find_by_channel(channel)
    end

    channel = "CMMB-00-601-*"
    p = Program.create(channel: channel, name: Program::CMMB_SID_GLOBAL_PROGRAMS["601"])
    assert_not_nil p

    channel = "CMMB-32-601-杭州"
    program = nil

    assert_no_difference "Program.count" do
      program = Program.find_by_channel(channel)
    end
    assert_equal p, program
  end

  test "comments_for_app" do
    p = create(:program)

    10.times do
      p.comments << Comment.create(channel: p.channel, body: "test", mac: "b8:70:f4:03:43:06")
    end

    5.times do
      p.comments << Comment.create(channel: p.channel, body: "test", mac: "b8:70:f4:03:43:06", created_at: Time.now - 5.hour)
    end

    assert_equal p.comments.count, 15

    1.upto(10) do |limit|
      assert_equal p.comments_in_4_hour_for_app(limit: limit).count, limit
    end

    assert_equal p.comments_in_4_hour_for_app.count, 10


    comments = p.comments_in_4_hour_for_app(limit: 5)
    id_largest_comment = comments.first
    id_smallest_comment = comments.last
    comments.each do |c|
      assert c.id <= id_largest_comment.id
      assert c.id >= id_smallest_comment.id
    end

    second_comments = p.comments_in_4_hour_for_app(id: id_smallest_comment.id, limit: 5)
    second_comments.each do |c|
      assert c.id < id_smallest_comment.id
    end
  end

  test "comments_in_4_hour_for_app return comments in order" do
    p = create(:program)

    c1 = create(:comment)
    p.comments << c1

    c2 = create(:comment)
    p.comments << c2

    c3 = create(:comment)
    p.comments << c3

    assert_equal p.comments_in_4_hour_for_app.to_a, [c3, c2, c1]
  end
end
