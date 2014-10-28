class App < ActiveRecord::Base
  belongs_to :app_version

  validates :mac, presence: true, uniqueness: true

end
