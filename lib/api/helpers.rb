#coding:utf-8
Dir["#{Rails.root}/lib/api/helpers/*.rb"].each { |file| require file }

module API
  module Helpers
    # ToDo: Is there any way to load all the helpers once?
    include API::Helpers::OAuth
    include UnifyAuthentication

    # def current_user
    #   @current_user ||= User.find_by_authentication_token(params[:private_token] || env["HTTP_PRIVATE_TOKEN"])
    # end

    def paginate(object)
      object.page(params[:page]).per(params[:per_page].to_i)
    end

    def authenticate!
      Rails.logger.debug headers

      session = {}
      cookies.each do |k, v|
        session[k] = v
        break
      end

      token = headers["X-Csrf-Token"]
      if token.present?
        Rails.logger.debug "token: #{token}"
        Rails.logger.debug "session: #{session}"
        if session.present?
          keys = $redis.keys("user:*")
          find = keys.one? do |user|
              h = $redis.hgetall(user)
              cookie = JSON.parse(h["cookie"])
              session == cookie
            end
          unless find
            Rails.logger.debug "session not find in redis"
            render_api_error!('401 Unauthorized, please re login got new session', 402)
          else
            Rails.logger.debug "session is find in redis, ok."
          end
        else
          #Rails.logger.debug "cookie not exist"
          render_api_error!('401 Unauthorized, session not find in request', 401)
        end
      else
        # render_api_error!('401 Unauthorized, please re login got new session', 402)
        Rails.logger.debug "token not exist"
      end
    end

    # def authenticated_as_admin!
    #   forbidden! unless current_user.is_admin?
    # end

    # def authorize! action, subject
    #   unless abilities.allowed?(current_user, action, subject)
    #     forbidden!
    #   end
    # end

    # error helpers

    def forbidden!
      render_api_error!('403 Forbidden', 403)
    end

    def bad_request!(attribute)
      message = ["400 (Bad request)"]
      message << "\"" + attribute.to_s + "\" not given"
      render_api_error!(message.join(' '), 400)
    end

    def not_found!(resource = nil)
      message = ["404"]
      message << resource if resource
      message << "Not Found"
      render_api_error!(message.join(' '), 404)
    end

    def unauthorized!
      render_api_error!('401 Unauthorized', 401)
    end

    def not_allowed!
      render_api_error!('Method Not Allowed', 405)
    end

    def render_api_error!(message, status, plain = false)
      message = {'message' => message} unless plain
      log_api_visit message, status
      error!(message, status)
    end

    def short_url
      request.url.to_s.gsub "http://#{request.host_with_port}", ''
    end

    def log_api_visit message = nil, status = nil
      begin
        api_version = env['api.version']
        request_type = env['REQUEST_METHOD']
        request = env['PATH_INFO'].sub("/#{api_version}/", '').sub('.json', '')

        #debug purpose for filter landing api
        return if request =~ /landing/


        # delete path and format, and attachment will be replaced as `file`
        request_data = params.reject { |k, v| k == 'route_info' || k == 'format' }.to_hash
        request_data.each do |k, v|
          if v.respond_to?(:has_key?) && v.has_key?('filename') && v.has_key?('type')
            request_data[k] = 'file'
          end
        end
        response_status = status ? status : env['api.endpoint'].status
        remote_ip = env['REMOTE_ADDR']
        response = message ? message : env['api.endpoint'].body

        # may response will be nil or sth like this which can't parse as JSON
        begin
          response = JSON.pretty_generate(response)
        rescue Exception => e
          response = response.inspect
        end

        debug = DebugLog.log_message
        duration = ((Time.now.to_f - @start) * 1000).to_i # ms
        warned = response.blank? || response == 'nil'

        ApiVisitLog.create!(api_version: api_version, request_type: request_type,
          request: request, request_data: JSON.pretty_generate(request_data),
          client_id: params[:client_id], remote_ip: remote_ip, warned: warned,
          response: response, response_status: response_status,
          debug: JSON.pretty_generate(debug), duration: duration)
      rescue Exception => e
        DebugLog.add_to_log exception: "写入访问日志出错#{e.message}" + e.backtrace.join("\n")
      ensure
        DebugLog.write_log
      end
    end


  end
end
