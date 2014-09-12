class Admin::CommentsController < AdminController

  def index
    if params[:channel].present?
      @comments = Comment.where(channel: params[:channel]).page(params[:page])
    else
      @comments = Comment.all.page(params[:page])
    end
  end

  def destroy
    @comment = Comment.find params[:id]
    @comment.destroy
  end

end
