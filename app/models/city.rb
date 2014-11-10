class City < ActiveRecord::Base
  has_many :programs
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, format: {with: /\A\d+\z/}
end
