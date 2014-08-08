# coding:utf-8
class Admin::AppVersionsController < AdminController

  set_tab :app_version_public, :sub_nav, except: :idnex
  # before_filter :setup, only: [:index]

  #default branch is public
  def index
    if personal?
      set_tab :app_version_personal, :sub_nav
      branch = "personal"
    else
      set_tab :app_version_public, :sub_nav
      branch = "public"
    end
    @app_versions = AppVersion.where(branch: branch).order('created_at desc')
  end

  def edit
    @app_version = AppVersion.find params[:id]
    render :new
  end

  def new
    @app_version = AppVersion.new
  end

  def create
    @app_version = AppVersion.new app_version_params
    if @app_version.save
      gflash success: "成功创建版本!"
      redirect_to admin_app_versions_path(branch: params[:app_version][:branch])
    else
      gflash error: "创建版本失败!"
      render :new
    end
  end

  def update
    @app_version = AppVersion.find params[:id]

    if @app_version.update app_version_params
      gflash success: "成功更新!"
      redirect_to admin_app_versions_path(branch: params[:app_version][:branch])
    else
      gflash success: "更新失败!"
      render :edit
    end
  end

  def destroy
    @app_version = AppVersion.find params[:id]
    @app_version.destroy
  end

  private

  def app_version_params
    params.require(:app_version).permit(:name, :version, :branch, :release, :note, :file, :itunes_url)
  end

  def setup
    @ways = ["发布管理", "公众版", "客户端"]
    @left_panel = "admin/app_versions/left_panel"
  end

end

