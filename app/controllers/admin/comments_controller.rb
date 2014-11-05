class Admin::CommentsController < AdminController
  before_action :setup
  set_tab :apis
  set_tab :comments, :sub_nav

  #test perclip parameters for grape use
  # skip_before_filter :verify_authenticity_token
  # def create
  #   # binding.pry
  #   c = Comment.new(params.permit(:audio))
  #   c.mac = "11:22:33:44:ff:ee"
  #   c.channel = "22-33-44-ff"
  #   c.content_type = "audio"
  #   if c.save
  #     render json: true
  #   else
  #     render json: c.errors.full_messages
  #   end
  # end

  def index
    if params[:program_id].present?
      @program = Program.find(params[:program_id])
      @comments = @program.comments.page(params[:page])
    elsif params[:channel].present?
      @comments = Comment.includes(:program).where(channel: params[:channle]).page(params[:page])
    else
      @comments = Comment.includes(:program).all.page(params[:page])
    end
  end

  def destroy
    @comment = Comment.find params[:id]
    @comment.destroy
  end


  private
  def setup
    @left_panel = "admin/programs/left_panel"
  end

end
