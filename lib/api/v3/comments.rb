# coding:utf-8
module API::V3
  class Comments < Grape::API

    resource :comments do

      desc "create a comment"
      params do
        requires :mac, type: String, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
        requires :channel, type: String, regexp: Program::CHANNEL_FORMAT
        requires :body, type: String
        optional :parent_id, type: Integer
      end
      post :create do
        mac = params[:mac]
        channel = params[:channel]
        body = params[:body]
        parent_id = params[:parent_id]

        program = Program.find_or_create_by_channel(params[:channel])
        comment = Comment.new mac: mac, channel: channel, body: body, parent_id: parent_id

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
            ancestor = c.ancestor.map {|a| {id: a.id, body: a.body, created_at: a.created_at}}
            {id: c.id, body: c.body, created_at: c.created_at.to_i, ancestor: ancestor}
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
