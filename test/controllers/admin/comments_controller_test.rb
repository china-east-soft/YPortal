require 'test_helper'
include Devise::TestHelpers

class Admin::CommentsControllerTest < ActionController::TestCase

  test "should get index" do
    3.times do
      create(:comment)
    end

    sign_in create(:admin)
    get :index
    assert_response :success, @response.body
  end

  test "should delete comment" do
    comment = create(:comment)
    sign_in create(:admin)

    assert_difference "Comment.count", -1 do
      xhr :delete, :destroy, id: comment
    end
  end

end
