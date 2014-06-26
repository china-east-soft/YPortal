class Wifi::MerchantsController < WifiController

  include PrivateKey
  include Communicate
  include Vtoken

  def home
    if request.env['HTTP_USER_AGENT'].to_s.match /CaptiveNetworkSupport/
      $redis.set("CaptiveNetworkSupport##{params[:mac].downcase}##{params[:client_identifier]}", Time.now.to_i)
      render text: 'ok'
    else
      process_wifi
    end
  end

  def process_wifi
    ##### preview, required: mid #####
    if params[:mid].present?
      @terminal = Terminal.where(status: Terminal.statuses[:active], mid: params[:mid]).first
    ##### preview end #####
    ##### client, required: vtoken #####
    elsif params[:vtoken].present?
      @auth_token = AuthToken.where(auth_token: params[:vtoken]).first
      if @auth_token.present?
        @auth_token.update_status
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
        if Terminal.exists?(status: Terminal.statuses[:active], mac: params[:mac].downcase)
          AuthToken.update_expired_status(params[:mac].downcase)
          @auth_token = AuthToken.where(client_identifier: params[:client_identifier], mac: params[:mac].downcase, status: [AuthToken.statuses[:init], AuthToken.statuses[:active]]).first
          ##### if rebooting terminal, the auth_token exists
          if @auth_token
            @auth_token.update_status
            case @auth_token.status
            when "init"
              Thread.new do
                test_wifi_connection
                ActiveRecord::Base.connection.close
              end
              redirect_to wifi_merchant_url(vtoken: @auth_token.auth_token, userAgent: params[:userAgent])
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
              Thread.new do
                test_wifi_connection
                ActiveRecord::Base.connection.close
              end
              vtoken = generate_vtoken params[:mac], params[:client_identifier], Time.now.to_i
              @auth_token = AuthToken.new( auth_token: vtoken,
                                          mac: params[:mac].downcase,
                                          client_identifier: params[:client_identifier],
                                          status: AuthToken.statuses[:init],
                                          terminal_id: terminal.id,
                                          merchant_id: terminal.merchant_id )
              @auth_token.save!

              redirect_to wifi_merchant_url(vtoken: @auth_token.auth_token, userAgent: params[:userAgent])
            else
              gflash :error => "请连接wifi!"
              render :error
            end
          end
        else
          gflash :error => "请连接wifi!"
          render :error
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
  end

  def test
  end

  def test_wifi_connection
    captive_time = $redis.get("CaptiveNetworkSupport##{params[:mac].downcase}##{params[:client_identifier]}")
    if captive_time && captive_time.to_i > Time.now.to_i - 10
      terminal = Terminal.where(["mac = ? and status = ? and merchant_id is not null",params[:mac].downcase, Terminal.statuses[:active]]).first
      vtoken = generate_vtoken params[:mac], params[:client_identifier], Time.now.to_i
      @auth_token = AuthToken.new( auth_token: vtoken,
                                mac: params[:mac].downcase,
                                client_identifier: params[:client_identifier],
                                status: AuthToken.statuses[:test],
                                terminal_id: terminal.id,
                                merchant_id: terminal.merchant_id )
      @auth_token.save!
      terminal = @auth_token.terminal
      duration = 15
      @auth_token.update_and_send_to_terminal(expired_timestamp: Time.now.to_i + duration, duration: duration, status: AuthToken.statuses[:test])
    end
  end

end
