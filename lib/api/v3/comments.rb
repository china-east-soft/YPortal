# coding:utf-8
module API::V3
  class Comments < Grape::API

    resource :comments do

      desc "create a comment"
      params do
        requires :mac, type: String
        requires :channel, type: String
        requires :body, type: String
      end
      post :create do
        mac = params[:mac]
        channel = params[:channel]
        body = params[:body]

        program = Program.find_by(channel: params[:channle])
        comment = Comment.new mac: mac, channel: channel, body: body

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
        requires :channel, type: String

        optional :id, type: Integer
        requires :limit , type: Integer
      end
      get :select do
        channel = params[:channel]
        id = params[:id] || 0
        limit = params[:limit] || 20

        comments = Comment.comments_for_app(channel: channel, id: id, limit: limit)

        present :result, true
        # present :comments, comments.pluck(:id, :body, :created_at)

        present :comments, comments.map {|c| {id: c.id, body: c.body, created_at: c.created_at.to_i} }
      end

      desc "query program name by channel"
      params do
        requires :channel, type: String
      end
      get :program_name do
        if program = Program.find_by(channel: params[:channel])
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
