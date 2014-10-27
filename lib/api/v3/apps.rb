# coding:utf-8
module API::V3
  class Apps < Grape::API
    resource :apps do
      desc "app is start "
      params do
        requires :mac, type: String
        optional :version, type: String
      end
      post '/start' do
        app = App.find_or_create_by(mac: params[:mac]) do
          if params[:version].present?
            name, version = params[:version].split("-")
            app_version = AppVersion.where(name: name, version: version, branch: 'personal')
            if app_version
              app.app_version = app_version
            end
          end
        end

        if app
          connection = AppConnectioin.new
          connection.app = app
          connection.save!

          present :result, true
        else
          not_found!
        end
      end

      desc "watching program"
      params do
        requires :mac, type: String
        requires :channel, type: String
        requires :started_at, type: String
        requires :seconds, type: Integer
        optional :user_id, type: Integer
      end
      post :watching do
        channel = params[:channel]
        program = Program.find_or_create_by_channel(channel)
        if program
          watching = Watching.new(started_at: params[:started_at], seconds: params[:seconds], program_id: program.id)
          watching.save
          present :result, true
        else
          not_found!("program")
        end
      end
    end
  end
end
