class ExternalTable < ActiveRecord::Base

  self.abstract_class = true

  establish_connection :readonly_db

  def readonly?
    true
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end

end
