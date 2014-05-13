class AuthToken < ActiveRecord::Base
  enum status: [ :init, :active, :expired ] 

  validates_uniqueness_of :client_identifier, scope: :mac, conditions: -> { where(status: [0, 1]) }
  

  def update_status
    if self.expired_timestamp.to_i < Time.now.to_i
      self.update_column(status: :expired)
    end
  end

end
