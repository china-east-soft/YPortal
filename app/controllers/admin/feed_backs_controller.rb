class Admin::FeedBacksController < AdminController
  skip_before_filter :authenticate_admin!, only: [:new, :create]

  before_action  :find_feed_back, only: [:show, :edit, :destroy, :update]

  set_tab :apis
  set_tab :feed_backs, :sub_nav, except: :new

  def new
    @feed_back = FeedBack.new(phone_type: params[:phone_type], client_version: params[:client_version], client_mac: params[:client_mac], terminal_version_name: params[:terminal_version_name], terminal_version: params[:terminal_version], terminal_mac: params[:terminal_mac])
    render layout: 'mobile'
  end

  def create
    @feed_back = FeedBack.new feed_back_prams
    if @feed_back.save
      respond_to do |format|
        format.html {
          flash[:success] = "非常感谢您的反馈！"

          request_params  = params[:feed_back]
          request_params.delete(:content)

          redirect_to feed_backs_new_url(request_params)
        }
      end
    else
      respond_to do |format|
        format.html {
          flash.now[:success] = "抱歉，反馈不成功！"
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
  end

  private
  def setup
    @left_panel = "admin/programs/left_panel"
  end
  def feed_back_prams
    params.require(:feed_back).permit(:content, :contact, :phone_type, :client_version, :client_mac, :terminal_version_name, :terminal_version, :terminal_mac)
  end

  def find_feed_back
    @feed_back = FeedBack.find params[:id]
  end

end
