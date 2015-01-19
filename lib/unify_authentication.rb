require 'rest_client'
# require 'nokorigi'

module UnifyAuthentication
  DOMAIN = 'http://cloudchain.co:8080'

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
        end
      rescue => e
        puts e.response
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
           token: doc.at_css("token").text,
          }
        end
      rescue => e
        #todo record error and retry
        puts e.response
      end
    end

    #cookie="sessid=session_name"
    def reg_device_token(cookie:, token:, device_token:)
      begin
        response = RestClient.post("#{DOMAIN}/api/acs_push", {token: device_token, type: "ios"}, Cookie: cookie, "X-CSRF-TOKEN" => token)
        if response.code == 200
          doc = Nokogiri::XML(response.body)
          {
           sessid: doc.at_css("sessid").text,
           session_name: doc.at_css("session_name").text,
           token: doc.at_css("token").text,
          }
        end
      rescue => e
        #todo record error and retry
        puts e.response
      end
    end

    def session_exist?(cookie: cookie, token: token)
      begin
        response = RestClient.get("#{DOMAIN}/api/acs_push", Cookie: cookie, "X-CSRF-TOKEN" => token)
        if response.code == 200
        end
        p response.body
      rescue => e
        #todo record error and retry
        puts e.response
      end
    end
  end

  include UserSystem
end

