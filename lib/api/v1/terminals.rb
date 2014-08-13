# coding:utf-8
module API::V1
  class Terminals < Grape::API

    params do
      requires :mac, type: String, regexp: /\A([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}\z/
    end

    resource :terminals do

      get :mid do
        terminal = Terminal.where(mac: params[:mac]).first
        if terminal
          present mid: terminal.mid, status: Terminal.statuses[terminal.status]
        else
          present error: 1
        end
      end

      desc "report terminal current version"
      params do
        requires :mac, type: String, regexp: CommonRegex::MAC
        requires :name, type: String
        requires :version, type: String
      end
      post 'version' do
        terminal = Terminal.find_by_mac(params[:mac])
        terminal_version = TerminalVersion.where(name: params[:name], version: params[:version]).first
        if terminal && terminal_version
          terminal.terminal_version = terminal_version
          result = terminal.save
        else
          result = false
        end
        present result: result
      end

      desc "update: get termianl latest version"
      params do
        requires :name, type: String
        requires :current_version, type: String
      end
      get :version do
        branch = ['public', 'personal', 'middleware', 'bootimage'].include?(params[:branch].to_s.downcase) ? params[:branch].to_s.downcase : 'public'
        client_terminalversion = TerminalVersion.where(
          version: params[:current_version],
          release: true,
          name: params[:name],
          branch: branch
        ).first
        if client_terminalversion == nil
          present :result, false
          present :message, 'invalid client version'
          present :error_code, 1
        else
          present :result, true
          latest_terminalversion = client_terminalversion
          enforce = false
          TerminalVersion.where(release: true, name: params[:name]).each do |terminalversion|
            latest_terminalversion = terminalversion if terminalversion.is_greater?(latest_terminalversion)
            enforce ||= terminalversion.enforce if terminalversion.is_greater?(client_terminalversion)
          end

          if latest_terminalversion == client_terminalversion
            present :is_latest, true
          else
            present :is_latest, false
            present :release_version, latest_terminalversion.version
            present :changelog, latest_terminalversion.note
            link = request.scheme + '://' + request.host_with_port + latest_terminalversion.file.url.to_s
            present :link, link
            present :enforce, enforce
          end
        end
      end
    end
  end
end
