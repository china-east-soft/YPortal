#coding:utf-8
require 'pp'

module API::V1

  MACS = {}

  class Root < Grape::API
    version 'v1', using: :path
    
    mount API::V1::AuthTokens
    mount API::V1::Ping
    mount API::V1::Accounts
  end
end