#coding:utf-8
require 'pp'

module API::V3

  MACS = {}

  class Root < Grape::API
    version 'v3', using: :path

    mount API::V3::Landings
    mount API::V3::Comments
    mount API::V3::Users
    mount API::V3::Messages
    mount API::V3::Apps
  end
end
