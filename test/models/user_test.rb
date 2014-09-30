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
    u2.valid?
    assert_not_nil u2.errors[:mobile_number]
  end

  test "must have name" do
    user = build(:user)
    user.name = nil

    user.valid?
    assert_not_nil user.errors[:name]
  end

end
