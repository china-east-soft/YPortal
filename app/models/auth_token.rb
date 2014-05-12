class AuthToken < ActiveRecord::Base
  enum status: [ :init, :active, :expired ] 

  validates_uniqueness_of :client_identifier, scope: :mac, conditions: -> { where(status: [:init, :active]) }
  

  def update_status
    if self.expired_timestamp < Time.now.to_i
      self.update_column(status: :expired)
    end
  end

end
