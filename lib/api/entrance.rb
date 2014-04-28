#coding:utf-8
require 'pp'

module API
  class Entrance < Grape::API
    class << self
      def logger
        Logger.new("#{Rails.root}/log/api.log")
      end
    end

    rescue_from ActiveRecord::RecordNotFound do
      rack_response({message: '404 Not found'}.to_json, 404)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      rack_response({
        status: e.status,
        message: e.message,
        errors: e.errors
      }.to_json, e.status)
    end

    rescue_from :all do |exception|
      # lifted from https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L60
      # why is this not wrapped in something reusable?
      trace = exception.backtrace

      message = "\n#{exception.class} (#{exception.message}):\n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
      message << "  " << trace.join("\n  ")
      API::Entrance.logger.add Logger::FATAL, message
      rack_response({message: '500 Internal Server Error'}.to_json, 500)
    end

    format :json
    default_format :json
    helpers API::Helpers

    unless Rails.env.test?
      http_basic do |username, password|
        { 'yunlian_portal' => 'china-east' }[username] == password
      end
    end

    before do
      @start = Time.now.to_f
    end

    mount API::V1::Root
  end
end
