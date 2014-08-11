class Admin::FeedBacksController < AdminController
  skip_before_filter :authenticate_admin!, only: [:new, :create]

  before_action  :find_feed_back, only: [:show, :edit, :destroy, :update]

  def new
    @feed_back = FeedBack.new
    render layout: 'mobile'
  end

  def create
    @feed_back = FeedBack.new feed_back_prams
    if @feed_back.save
      respond_to do |format|
        format.html {
          redirect_to admin_feed_backs_url
        }
        format.js {
        }
      end
    else
      respond_to do |format|
        format.html {
          render :new
        }
      end
    end
  end

  def index
    @feed_backs = FeedBack.all.page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    if @feed_back.update feed_back_prams
      redirect_to admin_feed_back_path(@feed_back)
    else
      render :edit
    end
  end

  def destroy
    @feed_back.destroy
    redirect_to admin_feed_backs_url
  end

  private
  def feed_back_prams
    params.require(:feed_back).permit(:content, :contact, :phone_type, :client_version, :terminal_name, :terminal_version)
  end

  def find_feed_back
    @feed_back = FeedBack.find params[:id]
  end

end
