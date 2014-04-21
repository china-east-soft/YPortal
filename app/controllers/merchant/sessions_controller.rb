class Merchant::SessionsController < Devise::SessionsController

  def auth
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
