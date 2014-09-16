class Admin::ProgramsController < AdminController

  def new
    @program = Program.new
  end

  def create
    @program = Program.new program_params
    if @program.save
      gflash :error, "创建失败, 请检查您的输入！"
      redirect_to admin_programs_url
    else
      gflash :success, "创建成功！"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def index
  end

  def destroy
  end

  private
  def program_params
    params.require(:program).permit(:name, :channel, :mode, :location, :feq, :sid)
  end

end
