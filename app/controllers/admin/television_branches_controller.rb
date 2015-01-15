class Admin::TelevisionBranchesController < AdminController
  before_action :setup
  before_action :find_branch, only: [:show, :update, :destroy]

  set_tab :apis
  set_tab :points, :sub_nav

  def new
    @branch = TelevisionBranch.new
  end

  def create
    @branch = TelevisionBranch.new branch_params
    if @branch.save
      redirect_to admin_television_branch_path(@branch), success: "创建成功"
    else
      render :new
    end
  end

  def show
  end

  def update
    if @branch.update(branch_params)
      redirect_to admin_television_branch_path(@branch), success: "更新成功"
    else
      render :show
    end
  end

  def index
    @branches = TelevisionBranch.all
  end

  def destroy
    @point_rule.destroy
    redirect_to admin_television_branchs_url
  end

  private
  def branch_params
    params.require(:television_branch).permit(:name, :desc)
  end

  def find_branch
    @branch = TelevisionBranch.find params[:id]
  end

  def setup
    @left_panel = "admin/programs/left_panel"
  end

end
