class Merchant::SessionsController < Devise::SessionsController

  layout 'devise'

  def auth
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
