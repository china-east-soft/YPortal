#coding:utf-8
require 'pp'

module API::V1
  class Root < Grape::API
    version 'v1', using: :path
    
    mount API::V1::AuthTokens
    mount API::V1::Ping
  end
end