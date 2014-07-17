class TerminalVersion < ActiveRecord::Base
  has_many :termnials

  validates :name, :version, :branch, :presence => true
  validates :version, :uniqueness => {:scope => :name}

end
