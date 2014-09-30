require 'test_helper'
include Devise::TestHelpers

class Admin::UsersControllerTest < ActionController::TestCase
  test "index page" do
    User.delete_all
    3.times do
      create(:user)
    end

    sign_in create(:admin)
    get :index
    assert_response :success, @response.body
  end

  test "delete user" do
    user = create(:user)
    sign_in create(:admin)

    assert_difference "User.count", -1 do
      xhr :delete, :destroy, id: user
    end
  end
end
