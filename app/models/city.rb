class City < ActiveRecord::Base
  has_many :programs, counter_cache: true

  has_many :comments, through: :programs

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, format: {with: /\A\d+\z/}

  def programs_by_branch(branch)
    programs.includes(:television).where(televisions: {branch: branch})
  end

end
