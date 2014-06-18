require 'test_helper'

class AdvertisesControllerTest < ActionController::TestCase
  setup do
    @landing = landings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:landings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create landing" do
    assert_difference('Advertise.count') do
      post :create, landing: { cover: @landing.cover, end_at: @landing.end_at, start_at: @landing.start_at, url: @landing.url }
    end

    assert_redirected_to landing_path(assigns(:landing))
  end

  test "should show landing" do
    get :show, id: @landing
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @landing
    assert_response :success
  end

  test "should update landing" do
    patch :update, id: @landing, landing: { cover: @landing.cover, end_at: @landing.end_at, start_at: @landing.start_at, url: @landing.url }
    assert_redirected_to landing_path(assigns(:landing))
  end

  test "should destroy landing" do
    assert_difference('Advertise.count', -1) do
      delete :destroy, id: @landing
    end

    assert_redirected_to landings_path
  end
end
