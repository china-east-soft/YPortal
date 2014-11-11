class Admin::CitiesController < AdminController
  before_action :find_city, only: [:show, :update, :destroy]
  before_action :setup

  set_tab :apis
  set_tab :cities, :sub_nav

  def new
    @city = City.new
  end

  def create
    @city = City.new city_params
    if @city.save
      flash[:success] = "添加成功"
      redirect_to admin_city_path(@city)
    else
      flash[:error] = "添加失败"
      render :new
    end
  end

  def show
  end

  def index
    @cities = City.all
  end

  def update
    if @city.update city_params
      flash[:success] = "修改成功"
      redirect_to admin_city_path(@city)
    else
      flash.now[:error] = "保存失败"
      render :show
    end
  end

  def destroy
    @city.destroy
    redirect_to admin_citys_url
  end

  private
  def find_city
    @city = City.find params[:id]
  end

  def city_params
    params.require(:city).permit(:name, :code)
  end
end
