class Merchant::MboxesController < MerchantController
  before_action :set_mbox, only: [:show, :edit, :update, :destroy]

  # GET /mboxes
  # GET /mboxes.json
  def index
    @mboxes = Mbox.all
  end

  # GET /mboxes/1
  # GET /mboxes/1.json
  def show
  end

  # GET /mboxes/new
  def new
    @mbox = Mbox.new
  end

  # GET /mboxes/1/edit
  def edit
  end

  # POST /mboxes
  # POST /mboxes.json
  def create
    @mbox = Mbox.new(mbox_params)

    respond_to do |format|
      if @mbox.save
        format.html { redirect_to @mbox, notice: 'Mbox was successfully created.' }
        format.json { render action: 'show', status: :created, location: @mbox }
      else
        format.html { render action: 'new' }
        format.json { render json: @mbox.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mboxes/1
  # PATCH/PUT /mboxes/1.json
  def update
    respond_to do |format|
      if @mbox.update(mbox_params)
        format.html { redirect_to @mbox, notice: 'Mbox was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mbox.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mboxes/1
  # DELETE /mboxes/1.json
  def destroy
    @mbox.update_column(:status, 0)
    respond_to do |format|
      format.html { redirect_to mboxes_url }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mbox
      @mbox = Mbox.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mbox_params
      params.require(:mbox).permit(:name, :integer, :portal_style_id, :category)
    end
end
