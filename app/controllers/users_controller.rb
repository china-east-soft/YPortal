class UsersController < ApplicationController
  layout "mobile"

  def index
    @users = User.order(points: :desc).first(10)
  end

end
