# coding:utf-8
require 'pp'

module API::V1
  class Ping < Grape::API

    params do
      requires :gw_id, type: String, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
    end

    resource :ping do
      get do
        API::Entrance.logger.add Logger::DEBUG, (request.url.to_s.gsub "http://#{request.host_with_port}", '')
        API::Entrance.logger.add Logger::DEBUG, params[:gw_id]
        API::Entrance.logger.add Logger::DEBUG, request.env["REMOTE_ADDR"]
        API::Entrance.logger.add Logger::DEBUG, request.port
        # pp request.port
        set_terminal_ip(params[:gw_id], request.env["REMOTE_ADDR"], request.port)
        present :pong
      end
    end

  end
end