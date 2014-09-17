class Admin::ProgramsController < AdminController
  before_action :find_program, only: [:show, :edit, :update, :destroy]

  def new
    @program = Program.new
  end

  def create
    @program = Program.new program_params
    if @program.save
      gflash success: "创建成功！"
      redirect_to admin_programs_url
    else
      gflash error: "创建失败, 请检查您的输入！"
      render :new
    end
  end

  def check_channel
    respond_to do |format|
      format.json do
        render json: !Program.where(channel: params[:program][:channel]).where.not(id: params[:id]).exists?
      end
    end
  end

  def show

  end

  def edit
  end

  def update
  end

  def index
    @programs = Program.page(params[:page])
  end

  def destroy
    @program.destroy
    gflash success: "删除成功"
    redirect_to admin_programs_url
  end

  private
  def program_params
    params.require(:program).permit(:name, :channel, :mode, :location, :feq, :sid)
  end

  def find_program
    @program = Program.find(params[:id])
  end

end
