#coding:utf-8
require 'net/http'
require 'socket'

class Wifi::UsersController < WifiController

  def login
    params[:account] ||= {}
  end

  def sign_in
    # if params[:verify].present?
    #   if params[:account][:mobile]
    #     auth_message = AuthMessage.where(mobile: params[:account][:mobile]).first_or_initialize
    #     if auth_message.save && auth_message.send_result > 0
    #       render action: :login
    #     else
    #       render action: :login
    #     end
    #   end
    # end

    #if params[:sign_in].present?
      params[:vtoken] = params[:account][:vtoken]
      if params[:account][:mobile] && params[:account][:verify_code] && params[:account] && params[:account][:vtoken]
        auth_message = AuthMessage.where(mobile: params[:account][:mobile], verify_code: params[:account][:verify_code]).first
        if auth_message
          auth_token = AuthToken.where(auth_token: params[:account][:vtoken]).first
          if auth_token
            case auth_token.status
              
            when "init"

            when "active"

            when "expired"

            end
            account = Account.where(mobile: params[:account][:mobile]).first_or_create
            if auth_token.update(expired_timestamp: Time.now.to_i + 4*3600, status: AuthToken.statuses[:active], account_id: account.id)
              logger.info(auth_token.mac)
              logger.info(auth_token.auth_token)
              logger.info(NatAddress.address(auth_token.mac.downcase))
              if address = NatAddress.address(auth_token.mac.downcase)
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
                expired_timestamp = ('00000000'+14400.to_s(16))[-8,8].split(//).each_slice(2).to_a.map{|i| i.join.to_i }.pack("S*")
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

                # i = 0; 
                # begin
                #  t = UDPSocket.new
                #  t.send(send_data, 0, remote_ip, port)
                #  begin
                #     recv_data = t.recv_nonblock(100); #也可用read_nonblock代替
                #     recv_data.strip!;
                #  rescue IO::WaitReadable
                #    i = i + 300;
                #    if i<max_delay #最大等待时间
                #       sleep(i/1000); # 等待1秒
                #       puts i
                #       #IO.select([t]); # 此行会导致recv_nonblock阻塞
                #       retry;
                #    end
                #  end
                #   t.close;
                # if recv_data.present?
                #   puts recv_data;
                # else
                #   puts "Server is not ok!";
                # end

                # rescue Errno::ECONNREFUSED
                #   ph_ok = false;
                #   puts "server not in listening!";
                # rescue Exception=>ex
                #   puts ex.to_s;
                # end

                if recv_data.present?
                  redirect_to wifi_welcome_url
                else
                  auth_token.update(status: 0)
                  render action: :login
                end

              else
                render action: :login
                
              end

            else
              @message = auth_token.errors
              render action: :login
            end
          else
            @message = "token is valid"
            render action: :login
          end
        else
          @message = "auth_message is missing"
          render action: :login
        end
      else
        @message = "手机号或者验证码不正确"
        render action: :login
      end
    end

  #end

end