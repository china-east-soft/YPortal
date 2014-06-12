class Admin::AuthMessagesController < AdminController

  def show
    msg = YAML.load(File.read(Rails.root.join  "config/auth_message.yml"))
    @message = msg["message"]
  end

  def update
  end

end
