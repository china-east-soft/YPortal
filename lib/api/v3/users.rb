# coding:utf-8
module API::V3
  class Users < Grape::API
    resource :users do
      desc "create user"
      params do
        requires :name, type: String
        requires :mobile_number, type: String, regexp: /\A\d{11}\z/
        requires :verify_code, type: String, regexp: /\A\d+\z/
        requires :password, type: String
        requires :password_confirmation, type: String
      end
      post :signup do
        user = User.find_by(mobile_number: params[:mobile_number])
        if user.present?
          error_code = 3

          present :result, false
          present :error_code, error_code
          present :message, "User already exist"
          return
        end

        mobile_number = params[:mobile_number]
        auth_message = AuthMessage.where(mobile: mobile_number).first

        if !auth_message || auth_message.verify_code != params[:verify_code]
          message = "verify code does not match"
          error_code = 1
        elsif auth_message.activated_at < Time.now
          message = "verify code is out of time"
          error_code = 2
        else
          user = User.new(name: params[:name],
                          mobile_number: mobile_number,
                          password: params[:password],
                          password_confirmation: params[:password_confirmation])
          if user.save
            error_code = 0
            HuanxinWorker.perform_async(user.id, :register_user)
          else
            error_code = 3
            message = user.errors.full_messages.join(",")
          end
        end

        if error_code == 0
          present :result, true
          present :user_id, user.id
        else
          present :result, false
          present :error_code, error_code
          present :message, message
        end
      end

      params do
        requires :signin, type: String, regexp: /\A(\d{11})|(([^@\s]+)@((?:[a-z0-9-]+\.)+[a-z]{2,}))\z/
        requires :password
      end
      post :signin do
        signin = params[:signin]
        user = if signin.include?("@")
                 User.where(email: signin).first
               else
                 User.where(mobile_number: signin).first
               end
        error_code = 0
        if user
          if user.authenticate(params[:password])
            present :result, true
            present :user_id, user.id
            present :name, user.name
            present :mobile_number, user.mobile_number
            present :avatar, user.avatar
          else
            error_code = 2
            message = "incorrect password"
          end
        else
          error_code = 1
          message= "use not exist"
        end

        if error_code != 0
          present :result, false
          present :message, message
          present :error_code, error_code
        end
      end

      params do
        requires :user_id, type: String
        requires :avatar, type: String
      end
      post :change_avatar do
        user = User.find(params[:user_id])
        if user
          user.avatar = params[:avatar]
          if user.save
            present :result, true
          else
            present :result, false
            present :message, user.errors.full_messages.join(",")
          end
        else
          present :result, false
          present :message, "user not exit"
        end
      end

      params do
        requires :mobile_number, type: String, regexp: /\A\d{11}\z/
        requires :password, type: String
        requires :password_confirmation, type: String
        requires :verify_code, type: String, regexp: /\A\d+\z/
      end
      post :reset_password_with_verify_code do

        mobile_number = params[:mobile_number]
        user = User.find_by(mobile_number: params[:mobile_number])

        error_code = 0
        if user.present?
          auth_message = AuthMessage.where(mobile: mobile_number).first

          if auth_message.nil? || auth_message.verify_code != params[:verify_code]
            message = "verify code does not match"
            error_code = 1
          elsif auth_message.activated_at < Time.now
            message = "verify code is out of time"
            error_code = 2
          else
            user.password = params[:password]
            user.password_confirmation = params[:password_confirmation]
            if user.save
              error_code = 0
              present :result, true
              present :user_id, user.id
              present :name, user.name
              present :mobile_number, user.mobile_number
              present :avatar, user.avatar
            else
              error_code = 3
              message = user.errors.full_messages.join(",")
            end
          end

        else
          error_code = 4
          message = "can not find user"
        end

        if error_code != 0
          present :result, false
          present :error_code, error_code
          present :message, message
        end
      end

      params do
        requires :user_id, type: String

        requires :old_password, type: String

        requires :password, type: String
        requires :password_confirmation, type: String
      end
      post :reset_password_with_old_password do

        user = User.find(params[:user_id])

        error_code = 0

        if user.present?
          if user.authenticate(params[:old_password])
            user.password = params[:password]
            user.password_confirmation = params[:password_confirmation]
            if user.save
              error_code = 0
              present :result, true
            else
              error_code = 3
              message = user.errors.full_messages.join(",")
            end
          else
            error_code = 2
            message = "incorrect password"
          end
        else
          error_code = 1
          message = "user not exist"
        end

        if error_code != 0
          present :result, false
          present :error_code, error_code
          present :message, message
        end
      end

      params do
        requires :user_id, type: String
        requires :name, type: String
      end
      post :change_name do
        user = User.find(params[:user_id])
        error_code = 0
        if user
          user.name = params[:name]
          if user.save
            present :result, true
            present :name, user.name
          else
            error_code = 2
            message = user.errors.full_messages.join(",")
          end
        else
          error_code = 1
          message = "user not exit"
        end

        if error_code != 0
          present :result, false
          present :message, message
        end
      end

    end
  end
end
