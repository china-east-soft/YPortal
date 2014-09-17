class Admin::CommentsController < AdminController

  def index
    if params[:program_id].present?
      @program = Program.find(params[:program_id])
      @comments = @program.comments.page(params[:page])
    elsif params[:channel].present?
      @program = Program.find_by(channel: params[:channel])
      @comments = @program.comments.page(params[:page])
    else
      @comments = Comment.includes(:program).all.page(params[:page])
    end
  end

  def destroy
    @comment = Comment.find params[:id]
    @comment.destroy
  end

end
