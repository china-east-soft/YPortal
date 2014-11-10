class Television < ActiveRecord::Base
  before_save do |record|
    record.name.upcase!
  end

  validates :name, uniqueness: {case_sensitive: false}
  has_many :programs
end
