class Account::RegistrationsController < Devise::RegistrationsController

  layout 'devise'

  before_filter :update_sanitized_params, if: :devise_controller?

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:mobile, :verify_code, :signing, :password, :password_confirmation)}
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:mobile, :email, :password, :password_confirmation, :current_password)}
  end

  # POST /resource
  def create
    mobile = sign_up_params[:mobile]
    if account = resource_class.where(mobile: mobile, encrypted_password: "").first
      account.assign_attributes(sign_up_params)
      resource = account
    else
      resource = build_resource(sign_up_params)
    end

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      # fix the mobile validates uniqueness
      sign_up_params.merge(fix_mobile_number: true)

      resource = build_resource(sign_up_params)
      resource_saved = resource.save

      clean_up_passwords resource
      respond_with resource
    end

  end

end