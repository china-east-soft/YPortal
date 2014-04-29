# coding:utf-8
require 'pp'

module API::V1
  class Ping < Grape::API

    params do
      requires :gw_id, type: String, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
    end

    resource :ping do
      get do
        # pp request.env["REMOTE_ADDR"]
        # pp request.port
        set_terminal_ip(params[:gw_id], request.env["REMOTE_ADDR"], request.port)
      end
    end

  end
end