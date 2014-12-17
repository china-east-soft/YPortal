class Admin::ExceptionLogsController < AdminController
  before_action :find_exception_log, only: [:show, :update, :destroy]
  before_action :setup

  set_tab :development
  set_tab :exception_logs, :sub_nav

  def index
    @exceptions = ExceptionLog.all
  end

  def show
  end

  def update
  end

  def destroy
  end

  private
  def find_exception_log
    @log = ExceptionLog.find params[:id]
  end

  def setup
    @left_panel = "admin/exception_logs/left_panel"
  end
end
