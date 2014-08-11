class Admin::FeedBacksController < AdminController

  skip_before_filter :authenticate_admin!, only: [:new, :create]

  def index
  end

  def new
    @feed_back = FeedBack.new
    render layout: 'mobile'
  end

end
