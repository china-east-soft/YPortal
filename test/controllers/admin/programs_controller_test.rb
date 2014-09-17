require 'test_helper'
include Devise::TestHelpers

class Admin::ProgramsControllerTest < ActionController::TestCase

  def setup
    sign_in create(:admin)
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should createt program" do
    assert_difference "Program.count" do
      post :create, program: attributes_for(:program)
    end
  end

  test "should redirect to index page after create" do
    post :create, program: attributes_for(:program)
    assert_redirected_to  '/admin/programs'
  end

  test "should check channel" do
    p = create(:program)

    #exist
    get :check_channel, program: { channel: p.channel }, format: 'json'
    assert_equal 'false', @response.body

    #not exist
    get :check_channel, program: { channel: build(:program).channel }, format: 'json'
    assert_equal 'true', @response.body
  end

  test "shold get show page" do
    p = create(:program)

    get :show, id: p.id
    assert_response :success, @response.body
  end

  test "should get index page" do
    get :index
    assert_response :success, @response.body
  end

  test "should get edit page" do
    p = create(:program)

    get :edit, id: p.id
    assert_response :success, @response.body
  end


  test "should delete program" do
    p = create(:program)

    assert_difference("Program.count", -1) do
      # xhr :delete, :destroy, id: p.id
      delete :destroy, id: p.id
    end

    assert_redirected_to admin_programs_url
  end

end
