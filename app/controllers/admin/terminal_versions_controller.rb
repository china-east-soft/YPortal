# coding:utf-8
class Admin::TerminalVersionsController < AdminController

  set_tab :release
  set_tab :terminal_version_public, :sub_nav, except: :index

  before_filter :setup

  def index

    if personal?
      set_tab :terminal_version_personal, :sub_nav
      branch = "personal"
    else
      set_tab :terminal_version_public, :sub_nav
      branch = "public"
    end

    @terminal_versions = TerminalVersion.where(branch: branch).order('created_at desc')
    @terminal_names = TerminalVersion.where(branch: branch).pluck(:name).uniq
  end

  def edit
    @terminal_version = TerminalVersion.find params[:id]
    render :new
  end

  def new
    @terminal_version = TerminalVersion.new
  end

  def create
    @terminal_version = TerminalVersion.new terminal_version_params
    if @terminal_version.save
      respond_to do |format|
        format.html {
          gflash success: "成功创建版本!"
          redirect_to admin_terminal_versions_path(branch: params[:terminal_version][:branch])
        }
      end
    else
      respond_to do |format|
        format.html {
          gflash error: "错误请求!"
          render :new
        }
      end
    end
  end

  def update
    @terminal_version = TerminalVersion.find params[:id]

    if @terminal_version.update terminal_version_params
      respond_to do |format|
        format.html {
          gflash success: "更新成功!"
          redirect_to admin_terminal_versions_path(branch: params[:terminal_version][:branch])
        }
      end
    else
      respond_to do |format|
        format.html {
          gflash error: "更新失败!"
          render :edit
        }
      end
    end
  end

  def destroy
    @terminal_version = TerminalVersion.find params[:id]
    @terminal_version.destroy
  end

  private

  def setup
    @ways = ["发布管理","终端"]
    @left_panel = "admin/app_versions/left_panel"
  end

  def terminal_version_params
    params.require(:terminal_version).permit(:name, :file, :branch, :version, :release, :note, :warning)
  end

end
