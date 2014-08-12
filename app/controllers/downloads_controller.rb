class DownloadsController < ApplicationController

  def index
    if params[:branch].present?
      branch = params[:branch]
    else
      branch = 'public'
    end
    @app = AppVersion.latest_release_by_name params[:name], branch
    unless @app
      redirect_to root_path
    else
      Download.create app_version: @app, remote_ip: request.env["REMOTE_ADDR"]
      case @app.name
      when 'ymtv_ios'
        redirect_to @app.itunes_url
      when 'ymtv_android'
        redirect_to @app.file.url
      else
        redirect_to root_path
      end
    end
  end

end
