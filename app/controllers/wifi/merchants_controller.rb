class Wifi::MerchantsController < WifiController

  def home

    if params[:vtoken]
      @url = "wifi/merchant?vtoken=#{params[:vtoken]}"
      if params[:client_identifier] && params[:mac]
        auth_token = AuthToken.where(auth_token: params[:vtoken]).first
        if auth_token
          if auth_token.init?
            flash[:success] = "点击认证，可以无线上网哦！！"
            render :home
          elsif auth_token.active?
            flash[:success] = "已经认证成功可以直接上网!"
            render :home
          elsif auth_token.expired?
            flash[:success] = "认证已经过期!"
            render :home
          end
        else
          auth_token = AuthToken.new( auth_token: params[:vtoken], 
                                      mac: params[:mac], 
                                      client_identifier: params[:client_identifier], 
                                      status: 0 )
          if auth_token.save!
            flash[:success] = "点击认证，可以无线上网哦！！"
            render :home
          else
            flash[:danger] = auth_token.errors
            render :error
          end
        end
      else
        auth_token = AuthToken.where(auth_token: params[:vtoken]).first
        if auth_token 
          if auth_token.init?
            flash[:success] = "点击认证，可以无线上网哦！！"
            render :home
          elsif auth_token.active?
            flash[:success] = "已经认证成功可以直接上网!"
            render :home
          elsif auth_token.expired?
            flash[:success] = "认证已经过期!"
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