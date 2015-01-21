require 'rest_client'
# require 'nokorigi'

module UnifyAuthentication
  DOMAIN = 'http://cloudchain.co:8080'
  ADMIN_PASSWORD = "jbgsn00"
  ADMIN_USERNAME = "Admin"

  module UserSystem
    #curl -X POST -i "http://cloudchain:8080/api/user/register" -d "name=138454522&pass=test&mail=kkk@gmail.com"
    #RestClient.post 'http://example.com/resource', :param1 => 'one', :nested => { :param2 => 'two' }
    def register_user(mobile_number:, password:, email: nil)
      name = mobile_number
      pass = password
      unless email
        mail = "#{mobile_number}@cloudchain.cn"
      end

      begin
        response = RestClient.post("#{DOMAIN}/api/user/register", name: name, pass: pass, mail: mail)
        if response.code == 200
          p response.body
          #uid?
          true
        else
          false
        end
      rescue => e
        puts e.response
        false
      end
    end

    def login(username:, password:)
      begin
        response = RestClient.post("#{DOMAIN}/api/user/login", username: username, password: password)
        if response.code == 200
          doc = Nokogiri::XML(response.body)
          {
            sessid: doc.at_css("sessid").text,
            session_name: doc.at_css("session_name").text,
            cookie: {doc.at_css("session_name").text => response.cookies[doc.at_css("session_name").text]},
            token: doc.at_css("token").text,
          }
        else
          false
        end
      rescue => e
        #todo record error and retry
        puts e.response
        false
      end
    end

    #cookie="sessid=session_name"
    def reg_device_token(cookie:, token:, device_token:)
      begin
        response = RestClient.post("#{DOMAIN}/api/acs_push", {token: device_token, type: "ios"}, {cookies: cookie, "X-CSRF-TOKEN" => token})
        if response.code == 200
          p response.body
          true
        else
          false
        end
      rescue => e
        #todo record error and retry
        puts e.response
        false
      end
    end

    def session_exist?(session_id)
      begin
        response = RestClient.post("#{DOMAIN}/api/acs_push/session", {sid: session_id}, cookies: admin_cookie, "X-CSRF-TOKEN" => admin_token)
        if response.code == 200
          p response.body
          true
        else
          false
        end
      rescue => e
        #todo record error and retry
        puts e.response
        false
      end
    end


    private
    def admin_cookie
      begin
        admin_info = $redis.hgetall("authentication")
        unless admin_info
          update_admin_session_and_token
          admin_info = $redis.hgetall("authentication")
        end

        JSON.parse(admin_info["cookie"])
      rescue => e
        Rails.logger.debug e
      end
    end

    def admin_token
      begin
        admin_info = $redis.hgetall("authentication")
        unless admin_info
          update_admin_session_and_token
          admin_info = $redis.hgetall("authentication")
        end

        admin_info["token"]
      rescue => e
        Rails.logger.debug e
      end
    end

    def update_admin_session_and_token
      result = login(username: ADMIN_USERNAME, password: ADMIN_PASSWORD)
      admin_token = result[:token]
      admin_cookie = result[:cookie].to_json
      $redis.hmset("authentication", "token", admin_token, "cookie", admin_cookie)
    end
  end

  include UserSystem
end

