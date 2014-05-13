# coding:utf-8
require 'pp'

module API::V1
  class Ping < Grape::API

    params do
      requires :gw_id, type: String, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
    end

    get :ping do
      present :pong
    end

  end
end