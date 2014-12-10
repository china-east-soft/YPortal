require 'digest/md5'
require 'rest_client'

module Huanxin
  DOMAIN = 'https://a1.easemob.com'
  ORG = 'hzcloudchain'
  APP = 'shiwangmo'
  CLIENT_ID  = 'YXA6gjPF0HqeEeSx0ZG3qEDc4g'
  CLIENT_SECRET = 'YXA6OKU7bQqpnr-Ymd0vu-CUboqpuL4'


  #curl -X POST -i "https://a1.easemob.com/easemob-demo/chatdemo/users" -d '{"username":"jliu","password":"123456"}'
  #RestClient.post 'http://example.com/resource', :param1 => 'one', :nested => { :param2 => 'two' }
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
          user.save!
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
        p body
        @access_token = body["access_token"]
        @expired_at = Time.now + body["expires_in"].to_i.seconds
        $redis.hmset("huanxin", "access_token", @access_token, "expired_at", @expired_at)
      end
    rescue => e
      puts e.response
    end
  end
end
