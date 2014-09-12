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

        comment = Comment.new mac: mac, channel: channel, body: body
        if comment.save
          present :result, true
        else
          present :result, false
          present :message, comment.errors.full_messaegs.join(",")
        end
      end


      desc "get comments"
      params do
        requires :mac, type: String
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
    end

  end
end
