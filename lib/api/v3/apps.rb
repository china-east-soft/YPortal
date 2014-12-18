# coding:utf-8
module API::V3
  class Apps < Grape::API
    resource :apps do
      desc "app boot"
      params do
        requires :mac, type: String
        optional :version, type: String
      end
      post '/boot' do
        app = App.find_or_create_by(mac: params[:mac])
        if app
          if params[:version].present?
            name, version = params[:version].split("-")
            app_version = AppVersion.where(name: name, version: version, branch: 'personal').first
            if app_version
              app.app_version = app_version
              app.save
            end
          end

          con = app.app_connections.order(created_at: :desc).first
          unless con && (con.created_at >= Time.zone.now.beginning_of_day && con.created_at <= Time.zone.now.end_of_day)
            app.app_connections << AppConnection.new
          end

          present :result, true
        else
          error_code = 1
          message = "app not found"
          present :result, false
          present :error_code, error_code
          present :message, message
        end
      end

      desc "watching program"
      params do
        requires :mac, type: String
        optional :channel, type: String
        optional :program_name, type: String
        requires :seconds, type: Integer
        optional :started_at, type: String
        optional :user_id, type: Integer
      end
      post :watching do
        error_code = 0
        channel = params[:channel]
        if channel
          program = Program.find_or_create_by_channel(channel)
          if program
            watching = Watching.new(started_at: params[:started_at], seconds: params[:seconds], program_id: program.id)
            watching.save!
          else
            error_code = 1
            message = "program not found"
          end
        elsif params[:program_name].present?
          watching = Watching.new(started_at: params[:started_at], seconds: params[:seconds], program_name: params[:program_name])
          watching.save!
        else
          error_code = 2
          message = "lack of params, channel and program_name need at last one"
        end

        if error_code == 0
          present :result, true
        else
          present :result, false
          present :errro_code, error_code
          present :message, message
        end
      end
    end
  end
end
