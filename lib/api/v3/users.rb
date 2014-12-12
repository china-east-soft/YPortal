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

      desc "follow user"
      params do
        requires :user_id, type: String
        requires :friend_id, type: String
      end
      post :follow do
        error_code = 0

        user = User.find params[:user_id]
        friend = User.find params[:friend_id]
        if user.following? friend
          error_code = 1
          message = "already follow user"
        elsif friend.blocked? user
          error_code = 2
          message = "user #{user.id} has been blocked by user #{friend.id}"
        elsif user.blocked? friend
          error_code = 3
          message = "user #{user.id} has blocked user #{friend.id}"
        else
          user.follow friend
        end

        if error_code == 0
          present :result, true
        else
          present :result, false
          present :message, message
        end
      end

      desc "unfollow user"
      params do
        requires :user_id, type: String
        requires :friend_id, type: String
      end
      post :unfollow do
        error_code = 0

        user = User.find params[:user_id]
        friend = User.find params[:friend_id]
        if user.following? friend
          user.unfollow friend
        else
          error_code = 1
          message = "not follow user"
        end

        if error_code == 0
          present :result, true
        else
          present :result, false
          present :message, message
        end
      end

      desc "get followed users"
      params do
        requires :user_id, type: String
        optional :page, type: Integer
        optional :per_page, type: Integer
      end
      get :following do
        user = User.find params[:user_id]
        per_page = params[:per_page].present? ? params[:per_page] : 20

        following = user.following.page(params[:page]).per(per_page)

        present :result, true
        present :following, following.map {|u| {id: u.id, nickname: u.name, avatar: u.avatar} }
      end

      desc "get followers"
      params do
        requires :user_id, type: String
        optional :page, type: Integer
        optional :per_page, type: Integer
      end
      get :followers do
        user = User.find params[:user_id]
        per_page = params[:per_page] || 20

        followers = user.followers.page(params[:page]).per(per_page)
        persent :result, true
        present :followers, followers.map {|u| { id: u.id, nickname: u.name, avatar: u.avatar } }
      end

      desc "block user"
      params do
        requires :user_id, type: String
        requires :blocked_id, type: String
      end
      post :block do
        error_code = 0

        user = User.find params[:user_id]
        blocked_user = User.find params[:blocked_id]

        if user.blocked? blocked_user
          error_code = 1
          message = "already block user"
        else
          user.block blocked_user
        end

        if error_code == 0
          present :result, true
        else
          present :result, false
          present :message, message
        end
      end

      desc "unblock user"
      params do
        requires :user_id, type: String
        requires :blocked_id, type: String
      end
      post :unblock do
        error_code = 0

        user = User.find params[:user_id]
        blocked_user = User.find params[:blocked_id]

        if user.blocked? blocked_user
          user.unblock blocked_user
        else
          error_code = 1
          message = "not blocked user"
        end

        if error_code == 0
          present :result, true
        else
          present :result, false
          present :message, message
        end
      end

      desc "get black list"
      params do
        requires :user_id, type: String
        optional :page, type: Integer
        optional :per_page, type: Integer
      end
      get :blacklist do
        user = User.find params[:user_id]
        per_page = params[:per_page].present? ? params[:per_page] : 20

        blocked_users = user.blocked_users.page(params[:page]).per(per_page)

        present :result, true
        present :blacklist, blocked_users.map {|u| {id: u.id, nickname: u.name, avatar: u.avatar} }
      end


      desc "get other user info"
      params do
        requires :current_user_id, type: String
        requires :other_user_id, type: String
      end
      get :other_user_info  do
        current_user = User.find params[:current_user_id]
        other_user = User.find params[:other_user_id]

        follow = current_user.following? other_user
        be_followed = other_user.following? current_user
        block =  current_user.blocked? other_user
        be_blocked = other_user.blocked? current_user

        comments = other_user.comments.order(created_at: :desc).first 20
        {
          nickname: other_user.name,
          avatar: other_user.avatar,
          relationship: {follow: follow, be_followed: be_followed, block: block, be_blocked: be_blocked},
          comments: comments
        }
      end

    end
  end
end
