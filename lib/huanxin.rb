require 'digest/md5'
require 'rest_client'

#todo  没有处理环信返回失败的情况， 不明确什么情况下会返回失败，以及什么操作导致
module Huanxin
  DOMAIN = 'https://a1.easemob.com'
  ORG = 'hzcloudchain'

  if Rails.env.testing?
    APP = 'shiwangmo'
    CLIENT_ID  = 'YXA6gjPF0HqeEeSx0ZG3qEDc4g'
    CLIENT_SECRET = 'YXA6OKU7bQqpnr-Ymd0vu-CUboqpuL4'
  elsif Rails.env.production?
    APP = 'shiwangmo4cn'
    CLIENT_ID  = 'YXA6G5t9EIv5EeSZOZvSZI_8RA'
    CLIENT_SECRET = 'YXA6u5xKWgHxadqrwyezTgJLWOIEyKA'
  elsif Rails.env.development?
    APP = 'hzcloudchainshiwangmo'
    CLIENT_ID  = 'YXA61nqZMH6AEeS6J3cUi1XKIg'
    CLIENT_SECRET = 'YXA6qSoE5mXrPiUqVp7k-PPJsrs8Pos'
  end

  USER_RESTFUL_API = %W[register_user unregister_user get_user_info]
  FRIEND_RESTFUL_API = %W[block_user unblock_user]

  # test for auction, can delete
  #http://cloudchain.co:8080/api/acs_push/push
  #uid=<uid>&note=<note>
  #uid为0，为群发；note为发送具体内容。内容可以是文本、图片、链接(Max=255个字符)。
  def send_note(note)
    begin
      url = "http://cloudchain.co:8080/api/acs_push/push"
      username = "admin"
      password = "jbgsn00"
      puts "#{username}:#{password}"
      resource = RestClient::Resource.new(url, username, password)
      response = resource.post({uid: 0, note: note}.to_json,
                               content_type: :json,
                               accept_type: :json
                              )
      if response.code == 200
        p response
      end
    rescue => e
      puts e.response
    end
  end


  #对应环信的用户体系集成
  module UserSystem
    #curl -X POST -i "https://a1.easemob.com/easemob-demo/chatdemo/users" -d '{"username":"jliu","password":"123456"}'
    #RestClient.post 'http://example.com/resource', :param1 => 'one', :nested => { :param2 => 'two' }
    # user的信息必须是完整的
    def register_user(user)
      username = Digest::MD5.hexdigest(user.id.to_s)
      password = Digest::MD5.hexdigest(user.id.to_s.reverse)
      nickname = user.name
      begin
        response = RestClient.post("#{DOMAIN}/#{ORG}/#{APP}/users",
                                  { username: username, password: password,
                                    nickname: nickname
                                  }.to_json,
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          body = JSON.parse(response.body)
          if body["entities"].first["activated"] == true
            user.username_huanxin = username
            user.register_huanxin = true
            user.save!
          end
        end
      rescue => e
        puts e.response
      end
    end

    #相环信发起注册， 用户的信息是空的
    def pre_register_user(user)
      username = Digest::MD5.hexdigest(user.id.to_s)
      password = Digest::MD5.hexdigest(user.id.to_s.reverse)
      begin
        response = RestClient.post("#{DOMAIN}/#{ORG}/#{APP}/users",
                                  { username: username,
                                    password: password,
                                  }.to_json,
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          body = JSON.parse(response.body)
          if body["entities"].first["activated"] == true
            user.username_huanxin = username
            user.register_huanxin = true
            user.save(validate: false)
          end
        end
      rescue => e
        puts e.response
      end
    end


    #curl -X DELETE -H "Authorization: Bearer YWMtSozP9jHNEeSQegV9EK5eAQAAAUlmBR2bTGr-GP2xNh8GhUCdKViBFgtox3M" -i  "https://a1.easemob.com/easemob-demo/chatdemoui/users/ywuxvxuir6"
    def unregister_user(user)
      username = Digest::MD5.hexdigest(user.id.to_s)
      begin
        response = RestClient.delete("#{DOMAIN}/#{ORG}/#{APP}/users/#{username}",
                                    "Authorization" => "Bearer #{access_token}",
                                    :accept => :json
                                    )
        if response.code == 200
          body = JSON.parse(response.body)
          if body["action"] == "delete"
            user.username_huanxin = nil
            user.register_huanxin = false

            #skip validate for pre reg users
            user.save(validate: false)
          end
        end
      rescue => e
        puts e.response
      end
    end

    #curl -X GET -H "Authorization: Bearer YWMtSozP9jHNEeSQegV9EK5eAQAAAUlmBR2bTGr-GP2xNh8GhUCdKViBFgtox3M" -i  "https://a1.easemob.com/easemob-demo/chatdemoui/users/ywuxvxuir6"
    def get_user_info(user)
      if user.respond_to? :id
        username = Digest::MD5.hexdigest(user.id.to_s)
      else
        username = user
      end

      begin
        url = "#{DOMAIN}/#{ORG}/#{APP}/users/#{username}"
        response = RestClient.get(url, "Authorization" => "Bearer #{access_token}", content_type: :json, accept: :json)
        res = JSON.parse(response.body)
        p res["entities"]
      rescue => e
        puts e.response
      end
    end

    #curl -X POST -H 'Authorization: Bearer YWMtwIRGSE9gEeSbpNnVBsIhiwAAAUon2XDyEBoBUk6Vg2xm8DZdVjxbhwm7XWY' -i  'https://a1.easemob.com/easemob-demo/chatdemoui/users/v3y0kf9arx/blocks/users' -d '{"usernames":["5cxhactgdj", "mh2kbjyop1"]}'
    def block_user(user, blocked_user)
      username = Digest::MD5.hexdigest(user.id.to_s)
      blocked_username = Digest::MD5.hexdigest(blocked_user.id.to_s)
      begin
        response = RestClient.post("#{DOMAIN}/#{ORG}/#{APP}/users/#{username}/blocks/users",
                                  { usernames: [blocked_username]
                                  }.to_json,
                                  "Authorization" => "Bearer #{access_token}",
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          p response

          body = JSON.parse(response.body)
          p body
        end
      rescue => e
        puts e.response
      end
    end

    #curl -X DELETE -H 'Authorization: Bearer YWMtwIRGSE9gEeSbpNnVBsIhiwAAAUon2XDyEBoBUk6Vg2xm8DZdVjxbhwm7XWY' -i  'https://a1.easemob.com/easemob-demo/chatdemoui/users/v3y0kf9arx/blocks/users/5cxhactgdj'
    def unblock_user(user, blocked_user)
      username = Digest::MD5.hexdigest(user.id.to_s)
      blocked_username = Digest::MD5.hexdigest(blocked_user.id.to_s)
      begin
        response = RestClient.delete("#{DOMAIN}/#{ORG}/#{APP}/users/#{username}/blocks/users/#{blocked_username}",
                                  "Authorization" => "Bearer #{access_token}",
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          p response

          body = JSON.parse(response.body)
          p body
        end
      rescue => e
        puts e.response
      end
    end

    #curl -X GET -H "Authorization: Bearer YWMtwIRGSE9gEeSbpNnVBsIhiwAAAUon2XDyEBoBUk6Vg2xm8DZdVjxbhwm7XWY" -i  "https://a1.easemob.com/easemob-demo/chatdemoui/users/v3y0kf9arx/blocks/users"
    def get_blacklist(user)
      username = Digest::MD5.hexdigest(user.id.to_s)
      begin
        response = RestClient.get("#{DOMAIN}/#{ORG}/#{APP}/users/#{username}/blocks/users",
                                  "Authorization" => "Bearer #{access_token}",
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          p response

          body = JSON.parse(response.body)
          p body
        end
      rescue => e
        puts e.response
      end
    end
  end

  module SendMessage
    #curl -X GET -i -H "Authorization: Bearer YWMtxc6K0L1aEeKf9LWFzT9xEAAAAT7MNR_9OcNq-GwPsKwj_TruuxZfFSC2eIQ" "https://a1.easemob.com/easemob-demo/chatdemoui/users/zw123/status"
    def get_user_status(user)
      username = Digest::MD5.hexdigest(user.id.to_s)
      begin
        response = RestClient.get("#{DOMAIN}/#{ORG}/#{APP}/users/#{username}/status",
                                  "Authorization" => "Bearer #{access_token}",
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          p response

          body = JSON.parse(response.body)
          p body
        end
      rescue => e
        puts e.response
      end
    end

    #curl -X POST -i -H "Authorization: Bearer YWMtxc6K0L1aEeKf9LWFzT9xEAAAAT7MNR_9OcNq-GwPsKwj_TruuxZfFSC2eIQ" "https://a1.easemob.com/easemob-demo/chatdemoui/messages" -d '{"target_type" : "users","target" : ["stliu1", "jma3", "stliu", "jma4"],"msg" : {"type" : "txt","msg" : "hello from rest"},"from" : "jma2", "ext" : {"attr1" : "v1","attr2" : "v2"} }'
    def send_text_message(from_user, to_user, message)
      from_username = Digest::MD5.hexdigest(from_user.id.to_s)
      to_username = Digest::MD5.hexdigest(to_user.id.to_s)
      begin
        response = RestClient.post("#{DOMAIN}/#{ORG}/#{APP}/messages",
                                  {
                                    target_type: "users",
                                    target: [to_username],
                                    msg: { type: "txt", msg: message},
                                    from: from_username
                                  }.to_json,
                                  "Authorization" => "Bearer #{access_token}",
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          p response

          body = JSON.parse(response.body)
          p body
        end
      rescue => e
        puts e.response
      end
    end

    #curl -X GET -H "Authorization: Bearer YWMtwIRGSE9gEeSbpNnVBsIhiwAAAUon2XDyEBoBUk6Vg2xm8DZdVjxbhwm7XWY" -i  "https://a1.easemob.com/easemob-demo/chatdemoui/users/v3y0kf9arx/offline_msg_count"
    def get_unread_message_count(user)
      username = Digest::MD5.hexdigest(user.id.to_s)
      begin
        response = RestClient.get("#{DOMAIN}/#{ORG}/#{APP}/users/#{username}/offline_msg_count",
                                  "Authorization" => "Bearer #{access_token}",
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          p response

          body = JSON.parse(response.body)
          p body
        end
      rescue => e
        puts e.response
      end
    end

  end

  module ChatHistroy
    #curl -X GET -i -H "Authorization: Bearer YWMtxc6K0L1aEeKf9LWFzT9xEAAAAT7MNR_9OcNq-GwPsKwj_TruuxZfFSC2eIQ" "https://a1.easemob.com/easemob-demo/chatdemoui/chatmessages?ql=select+*+where+timestamp%3C1403164734226+and+timestamp%3E1403163586000"
    def get_chat_histroy#(user)
      # username = Digest::MD5.hexdigest(user.id.to_s)
      begin
        response = RestClient.get("#{DOMAIN}/#{ORG}/#{APP}/chatmessages",
                                  "Authorization" => "Bearer #{access_token}",
                                  :content_type => :json,
                                  :accept => :json
                                  )
        if response.code == 200
          p response

          body = JSON.parse(response.body)
          p body
        end
      rescue => e
        puts e.response
      end

    end
  end



  include UserSystem
  include SendMessage
  include ChatHistroy

  private
  def access_token
    if @access_token && @expired_at > Time.now
      @access_token
    else
      set_or_update_admin_token
      @access_token
    end
  end

  def set_or_update_admin_token
    begin
      huanxin = $redis.hgetall("huanxin")
      if huanxin && huanxin["access_token"] && Time.parse(huanxin["expired_at"]) > Time.now
        @access_token = huanxin["access_token"]
        @expired_at = Time.parse(huanxin["expired_at"])
      else
        response = RestClient.post("#{DOMAIN}/#{ORG}/#{APP}/token",
                                    {
                                      grant_type: "client_credentials",
                                      client_id: CLIENT_ID,
                                      client_secret: CLIENT_SECRET
                                    }.to_json,
                                    content_type: :json,
                                    accept: :json
                                   )
        body = JSON.parse(response.body)
        @access_token = body["access_token"]
        @expired_at = Time.now + body["expires_in"].to_i.seconds
        $redis.hmset("huanxin", "access_token", @access_token, "expired_at", @expired_at)
      end
    rescue => e
      puts e.response
    end
  end

end
