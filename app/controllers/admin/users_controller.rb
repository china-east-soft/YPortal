class Admin::UsersController < AdminController
  before_action :find_user, except: :index

  def index
    @users = User.all.page(params[:page])
  end

  def show
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

end
