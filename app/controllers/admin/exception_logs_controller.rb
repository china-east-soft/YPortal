class Admin::ExceptionLogsController < AdminController
  before_action :find_exception_log, only: [:show, :update, :destroy]

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
end
