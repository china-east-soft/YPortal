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

    end

  end
end