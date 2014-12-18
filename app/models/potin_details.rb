class PotinDetails < ActiveRecord::Base
  belongs_to :user
  belongs_to :point_rule
end
