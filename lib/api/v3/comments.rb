# coding:utf-8
module API::V3
  class Comments < Grape::API
    # use ApiLogger

    resource :comments do

      desc "create a comment, can be text or audio"
      params do
        #ios can't get mac, so the mac is only an identify
        requires :mac, type: String#, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
        requires :channel, type: String#, regexp: Program::CHANNEL_FORMAT
        optional :parent_id, type: Integer
        optional :user_id, type: Integer

        #text or audio comment
        requires :body

        #audio comment
        optional :type, default: "text"
        optional :duration, type: Integer
      end
      post :create do
        mac = params[:mac]
        channel = params[:channel].force_encoding("UTF-8")
        parent_id = params[:parent_id]
        user_id = params[:user_id]

        type = params[:type]
        body = params[:body]

        program = Program.find_or_create_by_channel(params[:channel])
        if type == "audio"
          comment = Comment.new(mac: mac,
                                channel: channel,
                                parent_id: parent_id,
                                user_id: user_id,
                                duration: params[:duration])
          comment.audio = ActionDispatch::Http::UploadedFile.new(body)
          comment.content_type = "audio"
          # link = request.scheme + '://' + request.host_with_port + c.audio.url.to_s
        else
          body.force_encoding("UTF-8")
          comment = Comment.new(mac: mac, channel: channel, body: body, parent_id: parent_id, user_id: user_id)
        end

        if program.present?
          comment.program = program
        end

        if comment.save
          present :result, true
        else
          present :result, false
          present :message, comment.errors.full_messages.join(",")
        end
      end


      desc "get comments"
      params do
        optional :mac, type: String
        requires :channel, type: String#, regexp: Program::CHANNEL_FORMAT

        optional :id, type: Integer
        optional :limit , type: Integer
      end
      get :select do
        channel = params[:channel].force_encoding("UTF-8")
        id = params[:id] || 0
        limit = params[:limit] || 20

        program = Program.find_or_create_by_channel(channel)
        if program.present?
          television = program.television
          if television
            comments = television.parent_comments_in_4_hour_for_app(id: id, limit: limit)
          else
            comments = program.parent_comments_in_4_hour_for_app(id: id, limit: limit)
          end

          present :result, true
          comments_and_children = comments.map do |c|
            children = c.children.map {|child|
              if child.audio?
                body = request.scheme + '://' + request.host_with_port + child.audio.url.to_s
              else
                body = child.body
              end
              user_id = child.user_id
              user_name = child.user.try(:name)
              user_avatar = child.user.try(:avatar)
              {
               id: child.id, type: child.content_type, body: body,
               duration: child.duration, user_id: user_id, user_name: user_name,
               user_avatar: user_avatar, created_at: child.created_at
              }
            }
            if c.audio?
              body = request.scheme + '://' + request.host_with_port + c.audio.url.to_s
            else
              body = c.body
            end
            user_id = c.user_id
            user_name = c.user.try(:name)
            user_avatar = c.user.try(:avatar)
            {
              id: c.id, type: c.content_type, body: body,
              duration: c.duration,
              user_id: user_id, user_name: user_name, user_avatar: user_avatar,
              created_at: c.created_at.to_i, children: children
            }
          end
          present :comments, comments_and_children
        else
          present :result, false
          present :message, "找不到节目"
        end

      end

      desc "query program name by channel"
      params do
        requires :channel, type: String#, regexp: Program::CHANNEL_FORMAT
      end
      get :program_name do
        channel = params[:channel]
        if program = Program.find_or_create_by_channel(channel)
          present :result, true
          present :name, program.name
        else
          present :result, false
          present :message, "无法找到对应节目"
        end
      end
    end

  end
end
