class Wifi::MerchantsController < WifiController

  include PrivateKey

  def home

    if params[:vtoken].present?
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
        auth_token = AuthToken.where(client_identifier: params[:client_identifier], mac: params[:mac], status: [AuthToken.statuses[:init], AuthToken.statuses[:active]]).first
        if auth_token
          auth_token.update_status
          case auth_token.status
          when "init" 
            redirect_to wifi_merchant_url(vtoken: auth_token.auth_token)
          when "active"
            if params[:url].present?
              logger.info(auth_token.mac)
              logger.info(auth_token.auth_token)
              logger.info(NatAddress.address(params[:mac].downcase))
              if address = NatAddress.address(params[:mac].downcase)
                remote_ip, port, time = address.split("#")
                version = "\x00".force_encoding('UTF-8')
                type = "\x01".force_encoding('UTF-8')
                flag1 = "\xaa".force_encoding('UTF-8')
                flag2 = "\xbb".force_encoding('UTF-8')

                vtoken = auth_token.auth_token.force_encoding('UTF-8')

                mac = [auth_token.mac.gsub(/:/,'')].pack('H*').force_encoding('UTF-8')
                client_identifier = [auth_token.client_identifier.gsub(/:/,'')].pack('H*').force_encoding('UTF-8')
                #expired_timestamp = auth_token.expired_timestamp.to_s.scan(/../).map(&:hex).map(&:chr).join
                #expired_timestamp = auth_token.expired_timestamp.to_s(16)
                #expired_timestamp = "\x00\x00\x38\x40".force_encoding('UTF-8')
                expired_timestamp = sprintf("%6x", 14400)
                errcode = "\x00".force_encoding('UTF-8')
                attrnum = "\x01".force_encoding('UTF-8')

                send_data = "#{version}#{type}#{flag1}#{flag2}#{expired_timestamp}#{attrnum}#{errcode}#{vtoken}#{mac}#{client_identifier}\x00\x00"

                logger.info send_data

                max_delay= 1000

                t = UDPSocket.new
                t.send(send_data, 0, remote_ip, port)
                recv_data, addr = t.recvfrom(100);
                if recv_data
                  recv_data.strip!;
                  puts recv_data;
                end

                if recv_data.present?
                  redirect_to wifi_welcome_url
                else
                  redirect_to url = params[:url]
                end
              end
            else
              redirect_to wifi_merchant_url(vtoken: auth_token.auth_token)
            end
          end
        else
          vtoken = generate_vtoken params[:mac], params[:client_identifier], Time.now.to_i
          auth_token = AuthToken.new( auth_token: vtoken, 
                                      mac: params[:mac], 
                                      client_identifier: params[:client_identifier], 
                                      status: 0 )
          auth_token.save!
          redirect_to wifi_merchant_url(vtoken: auth_token.auth_token)          
        end
        
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