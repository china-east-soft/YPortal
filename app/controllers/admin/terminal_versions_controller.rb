# coding:utf-8
class Admin::TerminalVersionsController < AdminController

  # set_tab :release
  set_tab :terminal_version_public, :sub_nav, except: :index

  # before_filter :setup, only: [:index]

  def index

    if personal?
      set_tab :terminal_version_personal, :sub_nav
      branch = "personal"
    else
      set_tab :terminal_version_public, :sub_nav
      branch = "public"
    end

    @terminal_versions = TerminalVersion.where(branch: branch).order('created_at desc')
    # @terminal_names = TerminalVersion.where(branch: branch).pluck(:name).uniq
    @terminal_names = ["A-101", "A-102"]
  end

  def edit
    @terminal_version = TerminalVersion.find params[:id]
  end

  def new
    @terminal_version = TerminalVersion.new
  end

  def create
    @terminal_version = TerminalVersion.new params[:terminal_version]
    if @terminal_version.save
      respond_to do |format|
        format.js {  }
        format.html {
          redirect_to admin_terminal_versions_path(branch: params[:terminal_version][:branch])
        }
      end
    else
      respond_to do |format|
        format.js { render :action => :new  }
        format.html {
          setup
          render :action => :new
        }
      end
    end
  end

  def update
    @terminal_version = TerminalVersion.find params[:id]

    if @terminal_version.update_attributes(params[:terminal_version])
      respond_to do |format|
        format.js {  }
        format.html {
          redirect_to admin_terminal_versions_path(branch: params[:terminal_version][:branch])
        }
      end
    else
      respond_to do |format|
        format.js { render :action => :edit  }
        format.html {
          setup
          render :action => :edit
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

end
