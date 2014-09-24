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

  test "parent of comemnt" do
    c1 = create(:comment)
    c2 = create(:comment)
    c2.parent = c1
    c2.save

    assert_equal c1, c2.parent
  end

  test "children of commetn" do
    c1 = create(:comment)
    children = (1..10).map {
      Comment.create(body: "test", mac: c1.mac, channel: c1.channel, parent_id: c1.id)
    }

    assert_equal c1.children.to_a, children.reverse
  end

  test "ancestor" do
    c1 = create(:comment)
    assert c1.ancestor.empty?

    c2 = build(:comment)
    c2.parent = c1
    c2.save
    assert_equal c2.ancestor.to_a, [c1]

    c3 = build(:comment)
    c3.parent = c2
    c3.save
    assert_equal c3.ancestor.to_a, [c1, c2]
  end
end
