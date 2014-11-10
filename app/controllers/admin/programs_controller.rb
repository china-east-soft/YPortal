class Admin::ProgramsController < AdminController
  before_action :setup
  before_action :find_program, only: [:show, :edit, :update, :destroy]

  set_tab :apis
  set_tab :programs, :sub_nav

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
        render json: !Program.where('upper(channel) = ?', params[:program][:channel].upcase).where.not(id: params[:id]).exists?
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    if @program.update_attributes program_params
      redirect_to [:admin, @program], notice: 'program was successfully updated.'
    else
      render :edit
    end
  end

  def index
    # binding.pry
    if params[:page].nil? || params[:page].to_i == 1
      @global_programs = Program.global_programs
    end
    @programs = Program.local_programs.page(params[:page])
    # @programs = Program.page(params[:page])
  end

  def destroy
    @program.destroy
    gflash success: "删除成功"
    redirect_to admin_programs_url
  end

  private
  def program_params
    params.require(:program).permit(:name, :channel, :mode,
                                    :location, :feq, :sid, :television_id, :city_id)
  end

  def find_program
    @program = Program.find(params[:id])
  end

end
