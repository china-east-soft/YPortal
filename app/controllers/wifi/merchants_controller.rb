class Wifi::MerchantsController < WifiController

  def home

    if params[:vtoken]
      @url = "wifi/merchant?vtoken=#{params[:vtoken]}"
      # from teminal
      if params[:client_identifier] && params[:mac]

        # http_basic do |username, password|
        #   { 'yunlian_portal' => 'china-east' }[username] == password
        # end

        auth_token = AuthToken.where(auth_token: params[:vtoken]).first
        if auth_token
          # if auth_token.init?
          #   flash[:success] = "点击认证，可以无线上网哦！！"
          #   render :home
          # elsif auth_token.active?
          #   flash[:success] = "已经认证成功可以直接上网!"
          #   render :home
          # elsif auth_token.expired?
          #   flash[:success] = "认证已经过期!"
          #   render :home
          # end
        else
          auth_token = AuthToken.new( auth_token: params[:vtoken], 
                                      mac: params[:mac], 
                                      client_identifier: params[:client_identifier], 
                                      status: 0 )
          auth_token.save!
          # if auth_token.save!
          #   flash[:success] = "点击认证，可以无线上网哦！！"
          #   render :home
          # else
          #   flash[:danger] = auth_token.errors
          #   render :error
          # end
        end
        redirect_to wifi_merchant_url(vtoken: params[:vtoken]), status: 302
      else
        # only params[:vtoken], from client
        @auth_token = AuthToken.where(auth_token: params[:vtoken]).first
        if @auth_token.present?
          if @auth_token.init?
            render :home
          elsif @auth_token.active?
            flash[:success] = "已经认证成功可以直接上网!"
            render :home
          elsif @auth_token.expired?
            flash[:danger] = "认证已经过期!"
            render :home
          end
        else
          flash[:danger] = "请连接wifi!"
          render :error
        end
      end
    else
      flash[:danger] = "请连接wifi!"
      render :error
    end



  end

end