class Account < ActiveRecord::Base
  has_many :account_signins, dependent: :destroy
end
