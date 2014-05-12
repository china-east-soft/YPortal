# coding:utf-8
module API::V1
  class AuthTokens < Grape::API
    params do
      requires :mac, type: String, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
    end
    resource :auth_tokens do
      
      get do
        AuthToken.where(mac: params[:mac], status: 1).where(["expired_timestamp < :expired_timestamp", { expired_timestamp: Time.now.to_i }]).update_all(status: 2)
        auth_tokens = AuthToken.where(mac: params[:mac], status: 1).where(["expired_timestamp > :expired_timestamp", { expired_timestamp: Time.now.to_i }]).all
        if auth_tokens.present?
          auth_token_list = auth_tokens.map{|au| [au.client_identifier, au.auth_token, au.status, au.expired_timestamp.to_i - Time.now.to_i ].join(";") }
        else
          auth_token_list = []
        end
        present auth_token_list
      end

    end
  end
end