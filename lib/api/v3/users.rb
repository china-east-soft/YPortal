# coding:utf-8
module API::V3
  class Users < Grape::API
    resource :users do
      # 使用了环信的聊天服务，所以用户体系需要和环信融合(使用用户的id的md5作为环信的username，详情见oa上项目wiki)
      # 向环信发起注册我们的用户体系的时候因为网络或者环信的原因是有可能注册失败的，所以采用了预先向环信
      # 注册的方案。就是我们预先生成一批信息为空的user，使用这些user的id向环信注册。
      # 然后APP发起注册的时候再从这些user中选一个出来填上用户信息返回给app。
      # 如果预先注册的用户没有了，则会调用User.new 然后后台job向环新注册
      desc "create user"
      params do
        requires :mobile_number, type: String, regexp: /\A\d{11}\z/
        requires :verify_code, type: String, regexp: /\A\d+\z/
        requires :password, type: String
        requires :password_confirmation, type: String

        optional :name, type: String
        optional :gender, type: String, values: %W(male female)
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
          user = User.unused_reged_users.first

          if user
            user.name = params[:name]
            user.mobile_number = mobile_number
            user.gender = params[:gender]
            user.password = params[:password]
            user.password_confirmation = params[:password_confirmation]
            user.created_at = Time.zone.now

          else
            user = User.new(name: params[:name],
                            mobile_number: mobile_number,
                            gender: params[:gender],
                            password: params[:password],
                            password_confirmation: params[:password_confirmation])
          end

          if user.save
            error_code = 0
            #check in
            UserCheckIn.create_if_not_check_in_today_with(user: user)

            PointDetail.create_by_user_id_and_rule_name(user_id: user.id, rule_name: "用户注册")
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
        requires :user_id, type: String
        optional :name, type: String
        optional :gender, type: String, values: %W(male female)
        optional :avatar
        optional :avatar_type, values: %W(system custom)
      end
      post :profile do
        user = User.find params[:user_id]
        if params[:name]
          user.name = params[:name]
        end

        if params[:gender]
          user.gender = params[:gender]
        end

        avatar = params[:avatar]

        if avatar
          if params[:avatar_type] == "system"
            avatar.force_encoding("UTF-8")
            user.avatar = avatar
          else
            user.gravatar = ActionDispatch::Http::UploadedFile.new(avatar)
          end
          user.avatar_type = params[:avatar_type]
        end

        user.save

        present :result, true
        present :name, user.name
        present :mobile_number, user.mobile_number

        if user.custom_avatar?
          avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
        else
          avatar = user.avatar
        end
        present :avatar_type, user.avatar_type
        present :avatar, avatar
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

            if user.custom_avatar?
              avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
            else
              avatar = user.avatar
            end
            present :avatar_type, user.avatar_type
            present :avatar, avatar
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

              if user.custom_avatar?
                avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
              else
                avatar = user.avatar
              end

              present :avatar_type, user.avatar_type
              present :avatar, avatar
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
        present :following, following.map {|u|
          status = u.status
          program_id = u.program.try(:id)
          program_name = u.program.try(:name)
          program_guide_now = u.guide_now

          if u.custom_avatar?
            avatar = request.scheme + '://' + request.host_with_port + u.gravatar.url.to_s
          else
            avatar = u.avatar
          end

          {
            id: u.id, nickname: u.name, avatar: avatar, avatar_type: u.avatar_type, gender: u.gender, level: u.level, status: status,
            program: {id: program_id, name: program_name, guide_now: program_guide_now},
          }
        }
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
        present :followers, followers.map {|u|

          status = u.status
          program_id = u.program.try(:id)
          program_name = u.program.try(:name)
          program_guide_now = u.guide_now
          if u.custom_avatar?
            avatar = request.scheme + '://' + request.host_with_port + u.gravatar.url.to_s
          else
            avatar = u.avatar
          end

          {
            id: u.id,
            nickname: u.name,
            avatar_type: u.avatar_type,
            avatar: avatar,
            gender: u.gender,
            level: u.level,

            status: status,

            program: {id: program_id, name: program_name, guide_now: program_guide_now},
          }
        }
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

        present :blacklist, blocked_users.map {|u|
          if u.custom_avatar?
            avatar = request.scheme + '://' + request.host_with_port + u.gravatar.url.to_s
          else
            avatar = u.avatar
          end
          {id: u.id, nickname: u.name, avatar: avatar, avatar_type: u.avatar_type, gender: u.gender, level: u.level}
        }
      end


      desc "get user info, self of other user"
      params do
        requires :current_user_id, type: String
        optional :other_user_id, type: String
      end
      get :user_info  do
        current_user = User.find params[:current_user_id]

        if params[:other_user_id].present?
          other_user = User.includes(:program).find params[:other_user_id]

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

          status = other_user.status
          program_id = other_user.program.try(:id)
          program_name = other_user.program.try(:name)
          program_guide_now = other_user.guide_now

          if other_user.custom_avatar?
            avatar = request.scheme + '://' + request.host_with_port + other_user.gravatar.url.to_s
          else
            avatar = other_user.avatar
          end


          {
            result: true,
            nickname: other_user.name,
            gender: other_user.gender,
            avatar_type: other_user.avatar_type,
            avatar: avatar,
            relationship: relationship,
            comment_count: comment_count,
            topic_count: 0,
            level: other_user.level,

            status: status,

            program: {id: program_id, name: program_name, guide_now: program_guide_now,},
            location: {longitude: other_user.longitude, latitude: other_user.latitude,},
          }

        else
          comment_count = current_user.comments.count

          if current_user.custom_avatar?
            avatar = request.scheme + '://' + request.host_with_port + current_user.gravatar.url.to_s
          else
            avatar = current_user.avatar
          end

          {
            result: true,
            nickname: current_user.name,
            gender: current_user.gender,
            avatar_type: current_user.avatar_type,
            avatar: avatar,
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

        if user.custom_avatar?
          avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
        else
          avatar = user.avatar
        end

        present :result, true
        present :nickname, user.name
        present :avatar_type, user.avatar_type
        present :avatar, avatar
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
        if user.custom_avatar?
          avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
        else
          avatar = user.avatar
        end

        present :avatar_type, user.avatar_type
        present :avatar, avatar

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
          relationships: all_relations.map {|user|
            if user.custom_avatar?
              avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
            else
              avatar = user.avatar
            end

            {id: user.id, avatar_type: user.avatar_type, avatar: avatar, nickname: user.name, relationship: current_user.relationship_with(user) }
          },
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

        present :users, @users.map {|user|
          if user.custom_avatar?
            avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
          else
            avatar = user.avatar
          end

          {id: user.id,
           avatar_type: user.avatar_type,
           avatar: avatar,
           gender: user.gender,
           nickname: user.name,
           level: user.level
          #relationship: current_user.relationship_with(user)
          }
        }
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
        present :users, @users.map {|user|
          if user.custom_avatar?
            avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
          else
            avatar = user.avatar
          end

          {
           id: user.id,
           avatar_type: user.avatar_type,
           avatar: avatar,
           gender: user.gender,
           nickname: user.name,
           level: user.level
          #relationship: current_user.relationship_with(user)
          }
        }
      end


      desc "user on off line"
      params do
        requires :current_user_id, type: String
        requires :status, type: String, values: %W(online offline)
      end
      post :on_off_status do
        user = User.find params[:current_user_id]
        user.status = params[:status]
        user.save!

        present :result, true
      end

      desc "user location change"
      params do
        requires :current_user_id, type: String
        requires :longitude, type: Float
        requires :latitude, type: Float
      end
      post :location do
        user = User.find params[:current_user_id]
        user.longtitude = params[:longtitude]
        user.latitude = params[:latitude]
        user.save!

        present :result, true
      end

      desc "program that user is watching"
      params do
        requires :current_user_id, type: String
        optional :program_id, type: String
        optional :channel, type: String
      end
      post :watching do
        program_id = params[:program_id]
        channel = params[:channel]

        error_code = 0

        if (!program_id && !channel)
          error_code = 1
          message = "参数错误,program_id和channel必须有一个"
        else
          unless program_id
            program = Programs.find_by_channel(channel)
            program_id = program.try(:id)
          end

          if program_id
            user = User.find params[:current_user_id]
            user.program_id = program_id
            user.save
          end
        end

        if error_code == 0
          present :result, true
        else
          present :result, false
          present :error_code, error_code
          present :message, message
        end
      end

      desc "surround users"
      params do
        requires :current_user_id, type: String
        requires :latitude, type: Float
        requires :longitude, type: Float
        optional :distance, type: Integer, default: 1000
      end
      get :nearby_users do
        distance = params[:distance]/1000.0
        users = User.includes(:program).near([params[:latitude], params[:longitude]], distance, units: :km)

        current_user = User.includes(:program).find params[:current_user_id]
        blocked_users = current_user.blocked_users.includes(:program)
        be_blocked_users = current_user.blockers.includes(:program)

        users = users - [current_user] - blocked_users - be_blocked_users

        present :result, true
        present :users, users.map {|user|

          if user.custom_avatar?
            avatar = request.scheme + '://' + request.host_with_port + user.gravatar.url.to_s
          else
            avatar = user.avatar
          end
          {
           id: user.id,
           avatar_type: user.avatar_type,
           avatar: avatar,
           gender: user.gender,
           nickname: user.name,
           level: user.level,
           location: {longitude: user.longitude, latitude: user.latitude,},
           program: {id: user.program.id, name: user.program.name, guide_now: user.guide_now}
          #relationship: current_user.relationship_with(user)
          }
        }
      end
    end
  end
end
