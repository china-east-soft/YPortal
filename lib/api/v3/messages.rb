#coding:utf-8
module API::V3
  class Messages < Grape::API
    resource :messages do
      params do
        requires :mobile_number, type: String, regexp: /\A\d{11}\z/
      end
      post :verify_code do
        auth_message = AuthMessage.where(mobile: params[:mobile_number]).first_or_create(mobile: params[:mobile_number])
        if auth_message.save && auth_message.send_result > 0
          present :result, true
        else
          render_api_error!(false, 503)
        end
      end
    end
  end
end
