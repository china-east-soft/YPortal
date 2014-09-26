# coding:utf-8
module API::V3
  class Comments < Grape::API

    resource :comments do

      desc "create a comment, can be text or audio"
      params do
        requires :mac, type: String, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
        requires :channel, type: String, regexp: Program::CHANNEL_FORMAT
        optional :parent_id, type: Integer
        optional :user_id, type: Integer

        #text or audio comment
        requires :body

        #audio comment
        optional :type, default: "text"
      end
      post :create do
        mac = params[:mac]
        channel = params[:channel]
        parent_id = params[:parent_id]
        user_id = params[:user_id]

        type = params[:type]
        body = params[:body]

        program = Program.find_or_create_by_channel(params[:channel])
        if type == "audio"
          comment = Comment.new(mac: mac, channel: channel, parent_id: parent_id, user_id: user_id)
          comment.audio = ActionDispatch::Http::UploadedFile.new(body)
          comment.content_type = "audio"
          # link = request.scheme + '://' + request.host_with_port + c.audio.url.to_s
        else
          comment = Comment.new(mac: mac, channel: channel, body: body, parent_id: parent_id, user_id: user_id)
        end

        if program.present?
          comment.program = program
        end

        if comment.save
          present :result, true
        else
          present :result, false
          present :message, comment.errors.full_messaegs.join(",")
        end
      end


      desc "get comments"
      params do
        optional :mac, type: String
        requires :channel, type: String, regexp: Program::CHANNEL_FORMAT

        optional :id, type: Integer
        requires :limit , type: Integer
      end
      get :select do
        channel = params[:channel]
        id = params[:id] || 0
        limit = params[:limit] || 20

        program = Program.find_or_create_by_channel(channel)
        if program
          comments = program.comments_in_4_hour_for_app(id: id, limit: limit)

          present :result, true
          comments_and_ancestors = comments.map do |c|
            ancestor = c.ancestor.map {|a|
              if a.audio?
                body = request.scheme + '://' + request.host_with_port + a.audio.url.to_s
              else
                body = a.body
              end
              user_id = a.user_id
              user_name = a.user.try(:name)
              user_avatar = a.user.try(:avatar)
              {id: a.id, type: a.content_type, body: body, user_id: user_id, user_name: user_name, user_avatar: user_avatar, created_at: a.created_at}
            }
            if c.audio?
              body = request.scheme + '://' + request.host_with_port + c.audio.url.to_s
            else
              body = c.body
            end
            user_id = c.user_id
            user_name = c.user.try(:name)
            user_avatar = c.user.try(:avatar)
            {id: c.id, type: c.content_type, body: body, user_id: user_id, user_name: user_name, user_avatar: user_avatar, created_at: c.created_at.to_i, ancestor: ancestor}
          end
          present :comments, comments_and_ancestors
        else
          present :result, false
          present :message, "找不到节目"
        end

      end

      desc "query program name by channel"
      params do
        requires :channel, type: String, regexp: Program::CHANNEL_FORMAT
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
