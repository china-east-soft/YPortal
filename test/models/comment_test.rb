require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "should order by id" do
    c1 = create(:comment)
    c2 = create(:comment)
    assert_equal Comment.all.to_a, [c2, c1]
  end

  test "created_at is ordered as id order" do
    c1 = create(:comment)
    c2 = create(:comment)
    assert c2.created_at > c1.created_at
  end

  test "get all comments by comments_for_app" do
    c1 = create(:comment)
    19.times do
      create(:comment)
    end

    assert_equal Comment.count, 20
    assert_equal Comment.comments_for_app(channel: c1.channel, limit: 20).size, 20
  end

  test "get comments' ids less than spefic id" do
    5.times do
      create(:comment)
    end
    c1 = create(:comment)
    5.times do
      create(:comment)
    end

    comments = Comment.comments_for_app(channel: c1.channel, id: c1.id, limit: 5)
    comments.each do |c|
      assert c.id < c1.id
    end
  end

  test "limit work well of comments_for_app" do
    c1 = create(:comment)
    19.times do
      create(:comment)
    end
    20.times do |limit|
      assert_equal Comment.comments_for_app(channel: c1.channel, limit: limit).size, limit
    end
  end

end
