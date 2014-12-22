# coding:utf-8
module API::V3
  class Users < Grape::API
    resource :users do
      desc "create user"
      params do
        requires :name, type: String
        requires :mobile_number, type: String, regexp: /\A\d{11}\z/
        requires :verify_code, type: String, regexp: /\A\d+\z/
        optional :gender, type: String, values: %W(male female), default: "male"
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
                          gender: params[:gender],
                          password: params[:password],
                          password_confirmation: params[:password_confirmation])
          if user.save
            error_code = 0
            #check in
            UserCheckIn.create_if_not_check_in_today_with(user: user)
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
            #check in
            UserCheckIn.create_if_not_check_in_today_with(user: user)

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

      params do
        requires :user_id, type: String
        optional :name, type: String
        optional :gender, type: String, values: %W(male female)
      end
      post :change_name_or_gender do
        user = User.find(params[:user_id])
        error_code = 0
        if user
          user.name = params[:name] if params[:name].present?
          user.gender = params[:gender] if params[:gender].present?
          if user.save
            Rails.logger.debug "debug1"
            present :result, true
            present :name, user.name
            present :gender, user.gender
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
        requires :receiver_id, type: String
      end
      post :follow do
        error_code = 0

        user = User.find params[:user_id]
        friend = User.find params[:receiver_id]
        if user.following? friend
          error_code = 0
        elsif friend.blocked? user
          error_code = 1
          message = "user #{user.id} has been blocked by user #{friend.id}"
        else
          user.follow friend
        end

        if error_code == 0
          present :result, true
          present :user_id, user.id
          present :receiver_id, friend.id
          present :relation, user.relationship_with(friend)
        else
          present :result, false
          present :error_code, error_code
          present :message, message
          present :user_id, user.id
          present :receiver_id, friend.id
          present :relation, user.relationship_with(friend)
        end
      end

      desc "unfollow user"
      params do
        requires :user_id, type: String
        requires :receiver_id, type: String
      end
      post :unfollow do
        error_code = 0

        user = User.find params[:user_id]
        friend = User.find params[:receiver_id]
        if user.following? friend
          user.unfollow friend
        # else
        #   error_code = 1
        #   message = "not follow user"
        end

        if error_code == 0
          present :result, true
          present :user_id, user.id
          present :receiver_id, friend.id
          present :relation, user.relationship_with(friend)
        else
          present :result, false
          present :error_code, error_code
          present :message, message
          present :user_id, user.id
          present :receiver_id, friend.id
          present :relation, user.relationship_with(friend)
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
        present :following, following.map {|u| {id: u.id, nickname: u.name, avatar: u.avatar, gender: u.gender, level: u.level} }
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
        present :result, true
        present :followers, followers.map {|u| { id: u.id, nickname: u.name, avatar: u.avatar, gender: u.gender, level: u.level } }
      end

      desc "block user"
      params do
        requires :user_id, type: String
        requires :receiver_id, type: String
      end
      post :block do
        error_code = 0

        user = User.find params[:user_id]
        blocked_user = User.find params[:receiver_id]

        if user.blocked? blocked_user
          error_code = 0
          message = "already block user"
        else
          user.block blocked_user
        end

        if error_code == 0
          present :result, true
          present :user_id, user.id
          present :receiver_id, blocked_user.id
          present :relation, user.relationship_with(blocked_user)
        else
          present :result, false
          present :error_code, error_code
          present :message, message
        end
      end

      desc "unblock user"
      params do
        requires :user_id, type: String
        requires :receiver_id, type: String
      end
      post :unblock do
        error_code = 0

        user = User.find params[:user_id]
        blocked_user = User.find params[:receiver_id]

        if user.blocked? blocked_user
          user.unblock blocked_user
        end

        if error_code == 0
          present :result, true
          present :user_id, user.id
          present :receiver_id, blocked_user.id
          present :relation, user.relationship_with(blocked_user)
        else
          present :result, false
          present :error_code, error_code
          present :message, message
          present :user_id, user.id
          present :receiver_id, blocked_user.id
          present :relation, user.relationship_with(blocked_user)
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
        present :blacklist, blocked_users.map {|u| {id: u.id, nickname: u.name, avatar: u.avatar, gender: u.gender, level: u.level} }
      end


      desc "get user info, self of other user"
      params do
        requires :current_user_id, type: String
        optional :other_user_id, type: String
      end
      get :user_info  do
        current_user = User.find params[:current_user_id]

        if params[:other_user_id].present?
          other_user = User.find params[:other_user_id]

          follow = current_user.following? other_user
          be_followed = other_user.following? current_user
          block =  current_user.blocked? other_user
          be_blocked = other_user.blocked? current_user

          #0 stand for no relation
          relationship = 0

          if follow || be_followed
            if follow && !be_followed
              relationship = 1
            elsif be_followed && !follow
              relationship = 2
            elsif follow && be_followed
              relationship = 3
            end
          elsif block || be_blocked
            if block && !be_blocked
              relationship = 4
            elsif be_blocked && !block
              relationship = 5
            elsif block && be_blocked
              relationship = 6
            end
          end


          comment_count = other_user.comments.count

          {
            result: true,
            nickname: other_user.name,
            gender: other_user.gender,
            avatar: other_user.avatar,
            relationship: relationship,
            comment_count: comment_count,
            topic_count: 0,
            level: other_user.level
          }
        else
          comment_count = current_user.comments.count

          {
            result: true,
            nickname: current_user.name,
            gender: current_user.gender,
            avatar: current_user.avatar,
            comment_count: comment_count,
            topic_count: 0,
            level: current_user.level
          }
        end
      end

      desc "get user comments by page"
      params do
        requires :user_id, type: String
        optional :page, type: Integer
        optional :per_page, type: Integer
      end
      get :comments do
        user = User.find params[:user_id]
        per_page = params[:per_page].present? ? params[:per_page] : 20

        comments = user.comments.order(created_at: :desc).page(params[:page])
                       .per(per_page).map do |c|
          if c.audio?
            body = request.scheme + '://' + request.host_with_port + c.audio.url.to_s
          else
            body = c.body
          end
          {
            id: c.id, type: c.content_type, body: body,
            duration: c.duration,
            created_at: c.created_at.to_i
          }
        end

        present :result, true
        present :nickname, user.name
        present :avatar, user.avatar
        present :gender, user.gender
        present :level, user.level
        present :comments, comments
      end

      desc "get user info by huanxinname"
      params do
        requires :username, type: String
      end
      get :get_user_info_by_huanxin_username do
        user = User.find_by!(username_huanxin: params[:username])

        present :result, true
        present :id, user.id
        present :nickname, user.name
        present :avatar, user.avatar
      end

      desc "get user relationships: following and blacklist"
      params do
        requires :user_id, type: String
      end
      get :relationships do
        current_user = User.find params[:user_id]

        following = current_user.following
        blocked_users = current_user.blocked_users
        all_relations = following + blocked_users

        {
          result: true,
          relationships: all_relations.map {|user| {id: user.id, avatar: user.avatar, nickname: user.name, relationship: current_user.relationship_with(user) }},
        }
      end

      desc "get users by point order"
      params do
        optional :page, type: Integer
        optional :per_page, type: Integer
      end
      get :users_order_by_level do
        per_page = params[:per_page].present? ? params[:per_page] : 10

        @users = User.order(experience: :desc).page(params[:page]).per(per_page)
        present :result, true
        present :users, @users.map {|user| {id: user.id,
                                            avatar: user.avatar,
                                            nickname: user.name,
                                            level: user.level
                                      #relationship: current_user.relationship_with(user)
                                    }}
      end

      desc "search user by name"
      params do
        requires :name, type: String
      end
      get :search do
        if params[:name].present?
          @users = User.where('name like ?', "#{params[:name]}%")
        else
          @users = []
        end
        present :result, true
        present :users, @users.map {|user| {id: user.id,
                                            avatar: user.avatar,
                                            nickname: user.name,
                                            level: user.level
                                      #relationship: current_user.relationship_with(user)
                                    }}
      end
    end


  end
end
