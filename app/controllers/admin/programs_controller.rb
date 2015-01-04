class Admin::ProgramsController < AdminController
  before_action :find_program, only: [:show, :edit, :update, :destroy, :sort_up, :sort_down]

  set_tab :apis
  set_tab :programs, :sub_nav

  def new
    @program = Program.new(city_id: params[:city_id])
  end

  def create
    @program = Program.new program_params
    if @program.save
      gflash success: "创建成功！"

      if city = @program.city
        programs = city.programs_by_branch(@program.branch).page
        @last_page = programs.num_pages
      end

      redirect_to admin_programs_url(city_id: @program.city_id, page: @last_page, branch: @program.branch)
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
      position = params[:program][:position]
      if position.present? && (position.to_i > 0) && (position.to_i != @program.position)
        @program.insert_at(position.to_i)
      end

      if city = @program.city
        programs = city.programs_by_branch(@program.branch).page
        @last_page = programs.num_pages
      end

      redirect_to admin_programs_url(city_id: @program.city_id, page: @last_page, branch: @program.branch), notice: 'program was successfully updated.'
    else
      render :edit
    end
  end

  def index
    if params[:city_id].present?
      params[:branch] ||= "央视台"

      @city = City.find(params[:city_id])
      if @city
        @programs = @city.programs_by_branch(params[:branch]).page(params[:page])
      end
    else
      if params[:page].nil? || params[:page].to_i == 1
        @global_programs = Program.global_programs
      end
      @programs = Program.local_programs.page(params[:page])
    end

  end

  def sort_up
    @program.move_higher
    @program.city.touch(:epg_created_at)
    redirect_to admin_programs_url(city_id: @program.city_id, page: params[:page], branch: @program.branch)
  end

  def sort_down
    @program.move_lower
    @program.city.touch(:epg_created_at)
    redirect_to admin_programs_url(city_id: @program.city_id, page: params[:page], branch: @program.branch)
  end

  def destroy
    @program.destroy
    redirect_to admin_programs_url(city_id: @program.city_id, branch: @program.branch)
  end

  private
  def setup
    @left_panel = "admin/programs/left_panel"
  end
  def program_params
    params.require(:program).permit(:name, :mode, :freq, :sid, :television_id, :city_id)
  end

  def find_program
    @program = Program.find(params[:id])
  end

end
