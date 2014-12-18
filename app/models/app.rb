class App < ActiveRecord::Base
  belongs_to :app_version
  has_many :app_connections, dependent: :destroy, counter_cache: true

  validates :mac, presence: true, uniqueness: true

end
