require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "shoud have mobile number" do
    user = User.new(name: 'test', avatar: 'male-1', password: '12345')
    user.valid?
    assert_not_nil user.errors[:mobile_number]
  end

  test "mobile number should unique" do
    u1 = create(:user)

    u2 = build(:user)
    u2.mobile_number = u1.mobile_number
    u2.valid?
    assert_not_nil u2.errors[:mobile_number]
  end

  test "must have name" do
    user = build(:user)
    user.name = nil

    user.valid?
    assert_not_nil user.errors[:name]
  end

  test "should follow and unfollow a user" do
    u1 = create(:user)
    u2 = create(:user)
    assert_not u1.following? u2
    u1.follow u2
    assert u1.following? u2

    u1.unfollow u2
    assert_not u1.following? u2
  end

  test "should not follow self" do
    u1 = create(:user)

    assert_not u1.following? u1
    u1.follow u1
    assert_not u1.following? u1
  end

  test "should block and unblock a user" do
    u1 = create(:user)
    u2 = create(:user)
    assert_not u1.blocked? u2
    u1.block u2
    assert u1.blocked? u2

    u1.unblock u2
    assert_not u1.blocked? u2
  end

  test "can't follow block user" do
    u1 = create(:user)
    u2 = create(:user)

    u1.block u2
    assert u1.blocked? u2

    assert_not u1.following? u2
    u1.follow u2
    assert_not u1.following? u2
  end

  test "can follow block user after unblock" do
    u1 = create(:user)
    u2 = create(:user)

    u1.block u2
    assert u1.blocked? u2
    u1.unblock u2
    assert_not u1.blocked? u2

    assert_not u1.following? u2
    u1.follow u2
    assert u1.following? u2
  end

  test "block user should first unfoloow user" do
    u1 = create(:user)
    u2 = create(:user)

    u1.follow u2
    assert u1.following? u2

    assert_not u1.blocked? u2
    u1.block u2
    assert u1.blocked? u2
    assert_not u1.following? u2
  end

end
