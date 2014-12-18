class Admin::PointRulesController < AdminController
  before_action :setup
  before_action :find_rule, only: [:show, :update, :destroy]

  set_tab :apis
  set_tab :points, :sub_nav

  def new
    @point_rule = PointRule.new
  end

  def create
    @point_rule = PointRule.new point_rule_params
    if @point_rule.save
      redirect_to admin_point_rule_path(@point_rule), success: "创建成功"
    else
      render :new
    end
  end

  def show
  end

  def update
    if @point_rule.update(point_rule_params)
      redirect_to admin_point_rule_path(@point_rule), success: "创建成功"
    else
      render :show
    end
  end

  def index
    @rules = PointRule.all
  end

  def destroy
    @point_rule.destroy
    redirect_to admin_point_rules_url
  end

  private
  def point_rule_params
    params.require(:point_rule).permit(:name, :desc, :credit)
  end

  def find_rule
    @point_rule = PointRule.find params[:id]
    redirect_to admin_point_rules_url if PointRule::PREDEFINED_RULE_NAMES.include? @point_rule.name
  end

  def setup
    @left_panel = "admin/programs/left_panel"
  end
end
