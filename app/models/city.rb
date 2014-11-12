class City < ActiveRecord::Base

  has_many :programs
  has_many :comments, through: :programs

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, format: {with: /\A\d+\z/}


  def local_programs
    programs.includes(:television).where(televisions: {branch: 1})
  end

  def global_programs
    programs.includes(:television).where(televisions: {branch: 0})
  end


end
