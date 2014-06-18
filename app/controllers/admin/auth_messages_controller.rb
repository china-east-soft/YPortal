# encoding: UTF-8
class Admin::AuthMessagesController < AdminController

  def show
    #文件必须存在且可读
    msg = YAML.load(File.read(Rails.root.join  "config/auth_message.yml"))
    if msg
      @message = msg["message"]
    else
      @message = ""
    end
  end

  def update
    @message = params[:auth_message]
    @old_msg = YAML.load(File.read(Rails.root.join  "config/auth_message.yml"))["message"]

    if @message.present?
      if @message.include? '{verify_code}'
        origin_msg = File.read(Rails.root.join  "config/auth_message.yml")
        msg = {"message" => "#{@message}"}
        begin
          File.open(Rails.root.join("config/auth_message.yml"), 'w') do |f|
            f.write(YAML.dump msg)
          end
        rescue
          #文件必须存在且可写
          @error = "验证消息保存错误，请联系开发人员！"
          logger.debug "write file config/auth_message.yml failed!"
          File.open(Rails.root.join("config/auth_message.yml"), 'w') do |f|
            f.write(YAML.dump old_msg)
          end
        end
      else
        @error = '验证消息必须包含"{verify_code}"'
      end
    else
      @error = "验证消息不能为空"
    end
  end

end
