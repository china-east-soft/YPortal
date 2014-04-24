#coding:utf-8
require 'pp'

module API::V1
  class Root < Grape::API
    version 'v1', using: :path
  end
end