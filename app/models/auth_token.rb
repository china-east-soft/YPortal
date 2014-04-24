class AuthToken < ActiveRecord::Base
  enum status: [ :init, :active, :expired ] 
end
