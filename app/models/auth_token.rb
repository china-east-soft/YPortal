class AuthToken < ActiveRecord::Base
  enum status: [ :init, :active, :expired ] 

  validates_uniqueness_of :client_identifier, scope: :mac, conditions: -> { where(status: [AuthToken.statuses[:init], AuthToken.statuses[:active]]) }
  

  def update_status
    if self.expired_timestamp.to_i < Time.now.to_i
      self.update_columns(status: AuthToken.statuses[:expired])
    end
  end

end
