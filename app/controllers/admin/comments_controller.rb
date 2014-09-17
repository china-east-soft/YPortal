class Admin::CommentsController < AdminController

  def index
    if params[:program_id].present?
      @program = Program.find(params[:program_id])
      @comments = @program.comments.page(params[:page])
    else
      @comments = Comment.all.page(params[:page])
    end
  end

  def destroy
    @comment = Comment.find params[:id]
    @comment.destroy
  end

end
