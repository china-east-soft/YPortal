class Wifi::MerchantsController < WifiController

  include PrivateKey

  def home

    if params[:vtoken]
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
    else
      # from teminal
      if params[:client_identifier] && params[:mac]
        @url = "wifi/merchant?vtoken=#{params[:vtoken]}"
        auth_token = AuthToken.where(client_identifier: params[:client_identifier], mac: params[:mac], status: 0).first
        unless auth_token
          vtoken = generate_vtoken params[:mac], params[:client_identifier], Time.now.to_i
          auth_token = AuthToken.new( auth_token: vtoken, 
                                      mac: params[:mac], 
                                      client_identifier: params[:client_identifier], 
                                      status: 0 )
          auth_token.save!
        end
        redirect_to wifi_merchant_url(vtoken: auth_token.auth_token), status: 302
      else
        flash[:danger] = "请连接wifi!"
        render :error
      end
    end



  end

  private

    def generate_vtoken mac, client_identifier, timestamp
      # strip `:` in mac address and then reverse it
      reverse_mac = mac.delete(':').reverse
      reverse_client_identifier = client_identifier.delete(':').reverse
      # transfer the first and last half of it
      exchange_mac = [reverse_mac[6..11], reverse_mac[0..5], reverse_client_identifier[6..11], reverse_client_identifier[0..5]].sample(2).inject(:+)
      # generate a number array based on timestamp to perform sort
      sort_weight = Digest::MD5.hexdigest(timestamp.to_s)[0..23].chars.each_slice(2).map { |s| s.join.to_i 16 }
      # then sort it
      index = -1
      sort_mac = exchange_mac.chars.to_a.sort_by! { |k| sort_weight[index += 1] + index.to_f/100 }.join
      # hmac-sha1
      result = Base64.urlsafe_encode64(HMAC::SHA1.digest(private_key, sort_mac)).strip
      result
    end

end