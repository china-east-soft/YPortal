class Account::SessionsController < Devise::SessionsController

  layout 'devise'

  def after_sign_in_path_for(resource_or_scope)
    account_signing_path(mac: params[:mac], client_identifier: params[:client_identifier])
  end

  def auth
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
