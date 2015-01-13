class TelevisionBranch < ActiveRecord::Base
  has_many :televisions, dependent: :nullify

  acts_as_list

  validates_presence_of :name

  PREDEFINED_BRANCHES = ['央视台', '卫视台', '地方台']
end
