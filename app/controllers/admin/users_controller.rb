class Admin::UsersController < AdminController
  before_action :setup
  before_action :find_user, except: [:index, :unused_users]

  set_tab :apis
  set_tab :users, :sub_nav

  set_tab :development, only: %w(unused_users)
  set_tab :unused_users, :sub_nav, only: %w(unused_users)

  def index
    @users = User.order(experience: :desc).page(params[:page])
    respond_to do |format|
      format.html
      format.json { render json: @users}
    end
  end

  def unused_users
  end

  def show
    fresh_when(etag: [@user])
  end

  def update
    if @user.update_attributes params.require(:user).permit(:name, :avatar)
      gflash success: "更新成功!"
      redirect_to admin_user_url(@user)
    else
      gflash error: "更新失败, 请检查!"
      render :show
    end
  end

  def destroy
    @user.destroy
    gflash success: "删除用户成功！"
    redirect_to admin_users_url
  end


  private
  def find_user
    @user = User.find(params[:id])
  end

  def setup
    @left_panel = "admin/programs/left_panel"
  end

end
