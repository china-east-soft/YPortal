#coding:utf-8
require 'net/http'
require 'socket'

class Wifi::UsersController < WifiController

  def login

  end

  def sign_in
    if params[:verify].present?
      if params[:mobile]
        auth_message = AuthMessage.where(mobile: params[:mobile]).first_or_initialize
        if auth_message.save && auth_message.send_result > 0
          render action: :login
        else
          render action: :login
        end
      end
    end

    if params[:sign_in].present?
      if params[:mobile] && params[:verify_code] && params[:account] && params[:account][:vtoken]
        auth_message = AuthMessage.where(mobile: params[:mobile], verify_code: params[:verify_code]).first
        if auth_message
          auth_token = AuthToken.where(auth_token: params[:account][:vtoken]).first
          if auth_token
            account = Account.where(mobile: params[:mobile]).first_or_create
            if auth_token.update(expired_timestamp: 4*3600, status: 1, account_id: account.id)
              logger.info(auth_token.mac)
              logger.info(NatAddress.address(auth_token.mac.downcase))
              if address = NatAddress.address(auth_token.mac.downcase)
                logger.info "send uuuu"
                remote_ip, port, time = address.split("#")
                #send_data = "\x00\x05\xaa\xbb\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0c\x43\x76\x12\x34\x00\x0c\x43\x76\x12\x34\x00\x00\x00"
                version = "0x00"
                type = "Ox01"
                flag1 = "0xaa"
                flag2 = "0xbb"
                vtoken = auth_token.auth_token.scan(/../).map(&:hex).map(&:chr).join
                mac = auth_token.mac.gsub(/:/,'').scan(/../).map(&:hex).map(&:chr).join
                client_identifier = auth_token.client_identifier.gsub(/:/,'').scan(/../).map(&:hex).map(&:chr).join
                expired_timestamp = auth_token.expired_timestamp.to_s.scan(/../).map(&:hex).map(&:chr).join
                errcode = "0x00"
                attrnum = "0x01"

                send_data = [version,type,flag1,flag2,vtoken,mac,client_identifier,expired_timestamp,errcode,attrnum].join

                max_delay= 1000

                i = 0; 
                begin
                 t = UDPSocket.new
                 t.send(send_data, 0, remote_ip, port)
                 begin
                    recv_data = t.recv_nonblock(100); #也可用read_nonblock代替
                    recv_data.strip!;
                 rescue IO::WaitReadable
                   i = i + 300;
                   if i<max_delay #最大等待时间
                      sleep(1/1000); # 等待1秒
                      puts i
                      #IO.select([t]); # 此行会导致recv_nonblock阻塞
                      retry;
                   end
                 end
                  t.close;
                if recv_data.present?
                  puts recv_data;
                else
                  puts "Server is not ok!";
                end

                rescue Errno::ECONNREFUSED
                  ph_ok = false;
                  puts "server not in listening!";
                rescue Exception=>ex
                  puts ex.to_s;
                end

                if recv_data.present?
                  redirect_to wifi_welcome_url
                else
                  auth_token.update(status: 0)
                  redirect_to action: :login
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

  end

end