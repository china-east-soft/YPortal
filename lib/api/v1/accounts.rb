# coding:utf-8
module API::V1
  class Accounts < Grape::API
    params do
      requires :mac, type: String, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
      requires :vtoken, type: String
      requires :type, type: Integer
    end

    resource :accounts do
      delete :logout do
        auth_token = AuthToken.where(auth_token: params[:vtoken], mac: params[:mac]).first
        duration = 0
        if auth_token
          case auth_token.status
          when 'expired'
            error_code = 1 # expired
          when 'init'
            error_code = 2 # init
          when 'active'
            expired_timestamp = auth_token.expired_timestamp
            left_time = expired_timestamp - Time.now.to_i
            if left_time < 100
              if auth_token.update_columns(status: AuthToken.statuses[:expired])
                present :result, :ok
              end
            else
              duration = left_time
              error_code = 3
            end
          end
        else
          error_code = 4 # not exists
        end
        if error_code
          present :error, error_code
          present :duration, duration
        end
        
      end
    end


  end

end