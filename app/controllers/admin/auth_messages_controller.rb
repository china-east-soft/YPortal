# encoding: UTF-8
class Admin::AuthMessagesController < AdminController

  def show
    begin
      #文件必须存在且可读
      msg = YAML.load(File.read(Rails.root.join  "config/auth_message.yml"))
    rescue
      gflash error: "读取配置文件错误， 请联系开发人员！"
      logger.debug "***************************"
      logger.debug "config/auth_message does not existed or can't open"
      logger.debug "***************************"
    end
    if msg
      @message = msg["message"]
    else
      @message = ""
    end
  end

  def update
    @message = params[:auth_message]

    if @message.present?
      if @message.include? '{verify_code}'
        begin
          @old_msg = YAML.load(File.read(Rails.root.join  "config/auth_message.yml"))["message"]

          origin_file_content = File.read(Rails.root.join  "config/auth_message.yml")
          msg = {"message" => "#{@message}"}

          File.open(Rails.root.join("config/auth_message.yml"), 'w') do |f|
            f.write(YAML.dump msg)
          end
        rescue
          #文件必须存在且可写
          @error = "验证消息保存错误，请联系开发人员！"
          logger.debug "write file config/auth_message.yml failed!"
          File.open(Rails.root.join("config/auth_message.yml"), 'w') do |f|
            f.write(YAML.dump origin_file_content)
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
