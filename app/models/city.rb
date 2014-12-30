class City < ActiveRecord::Base
  has_many :programs, -> { order("position ASC") }, counter_cache: true, dependent: :nullify

  has_many :comments, through: :programs

  # default_scope { order(name: :asc) }

  validates :name, presence: true, uniqueness: {message: "(%{value})已经添加过了"}
  validates :code, presence: true, uniqueness: {casesensitive: true, message: "城市号码(%{value})已经被使用了" }, format: {with: /\A\d+\z/}

  def programs_by_branch(branch)
    programs.includes(:television).where(branch: branch)
  end
end
