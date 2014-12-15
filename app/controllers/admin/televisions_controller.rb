class Admin::TelevisionsController < AdminController
  before_action :find_television, only: [:show, :update, :destroy]
  before_action :setup

  set_tab :apis
  set_tab :televisions, :sub_nav

  def new
    @television = Television.new
  end

  def create
    @television = Television.new television_params
    if @television.save
      redirect_to admin_television_url(@television), success: "添加成功"
    else
      render :new
    end
  end

  def index
    @televisions = Television.all
  end

  def show
  end

  def update
    if @television.update(television_params)
      redirect_to admin_television_url(@television), success: " 修改成功"
    else
      render :show
    end
  end

  def destroy
    @television.destroy

    redirect_to admin_televisions_url
  end

  private
  def find_television
    @television = Television.find params[:id]
  end

  def television_params
    params.require(:television).permit(:name, :logo, :branch)
  end
end
