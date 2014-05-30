class Wifi::MerchantsController < WifiController

  include PrivateKey
  include Communicate

  def home
    ##### preview, required: mid #####
    if params[:mid].present?
      @terminal = Terminal.where(status: Terminal.statuses[:active], mid: params[:mid]).first
    ##### preview end #####
    ##### client, required: vtoken #####
    elsif params[:vtoken].present?
      @auth_token = AuthToken.where(auth_token: params[:vtoken]).first
      if @auth_token.present?
        if @auth_token.init?
          render :home
        elsif @auth_token.active?
          gflash :success => "已经认证成功可以直接上网!"
          render :home
        elsif @auth_token.expired?
          gflash :error => "认证已经过期，请重新认证!"
          redirect_to wifi_merchant_url(client_identifier: @auth_token.client_identifier, mac: @auth_token.mac)
        end
      else
        gflash :error => "请连接wifi!"
        render :error
      end
    ##### client end #####
    ##### terminal, required: client_identifier, mac #####
    else
      if params[:client_identifier] && params[:mac]
        AuthToken.update_expired_status(params[:mac].downcase)
        @auth_token = AuthToken.where(client_identifier: params[:client_identifier], mac: params[:mac].downcase, status: [AuthToken.statuses[:init], AuthToken.statuses[:active]]).first
        ##### if rebooting terminal, the auth_token exists
        if @auth_token
          @auth_token.update_status
          case @auth_token.status
          when "init"
            redirect_to wifi_merchant_url(vtoken: @auth_token.auth_token)
          when "active"
            if address = NatAddress.address(params[:mac].downcase)

              remote_ip, port, time = address.split("#")

              recv_data = send_to_terminal remote_ip, port, @auth_token, 1

              if recv_data.present?
                gflash :success => "已经认证成功可以直接上网!"
                redirect_to wifi_welcome_url(vtoken: @auth_token.auth_token)
              else
                message = "can not recv data..."
                Communicate.logger.add Logger::FATAL, message
                gflash :error => message
                # to do
                redirect_to wifi_welcome_url(vtoken: @auth_token.auth_token)
              end
            else
              message = "no nat address..."
              Communicate.logger.add Logger::FATAL, message
              gflash :error => message
              render :error
            end
          end
        ##### init
        else
          terminal = Terminal.where(["mac = ? and status = ? and merchant_id is not null",params[:mac].downcase, Terminal.statuses[:active]]).first
          if terminal
            vtoken = generate_vtoken params[:mac], params[:client_identifier], Time.now.to_i
            @auth_token = AuthToken.new( auth_token: vtoken,
                                        mac: params[:mac].downcase,
                                        client_identifier: params[:client_identifier],
                                        status: AuthToken.statuses[:init],
                                        terminal_id: terminal.id,
                                        merchant_id: terminal.merchant_id )
            @auth_token.save!
            redirect_to wifi_merchant_url(vtoken: @auth_token.auth_token)
          else
            gflash :error => "请连接wifi!"
            render :error
          end
        end

      else
        gflash :error => "请连接wifi!"
        render :error
      end

    end

  end

  def show

  end

  def welcome
    @merchant_info = terminal_merchant.merchant_info
  end

  def login_success
    # @merchant = terminal_merchant
    @merchant = current_merchant
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
