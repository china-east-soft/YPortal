class Admin::CitiesController < AdminController
  before_action :find_city, only: [:show, :update, :destroy, :enable_branch, :disable_branch]

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
    @cities = City.order(name: :asc).page(params[:page])
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

  def disable_branch
    @city.toggle(:enable_branch)
    @city.touch(:epg_created_at)
    @city.save
  end

  def enable_branch
    @city.toggle(:enable_branch)
    @city.touch(:epg_created_at)
    @city.save
  end

  def destroy
    @city.destroy
    redirect_to admin_cities_url
  end

  private
  def setup
    @left_panel = "admin/programs/left_panel"
  end

  def find_city
    @city = City.find params[:id]
  end

  def city_params
    params.require(:city).permit(:name, :code)
  end
end
