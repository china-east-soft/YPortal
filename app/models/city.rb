class City < ActiveRecord::Base
  has_many :programs, -> { order("position ASC") }, dependent: :destroy

  has_many :comments, through: :programs

  # default_scope { order(name: :asc) }

  validates :name, presence: true, uniqueness: {message: "(%{value})已经添加过了"}
  validates :code, presence: true, uniqueness: {casesensitive: true, message: "城市号码(%{value})已经被使用了" }, format: {with: /\A\d+\z/}

  def programs_by_branch(branch)
    programs.includes(:television).where(branch: branch)
  end

  def epg_guides
    @guides ||= if File.exist?("#{Rails.root.to_s}/public/cities/#{id}.json")
                  File.open("#{Rails.root.to_s}/public/cities/#{id}.json", 'r') do |f|
                    JSON.parse(f.read)
                  end
                end
  end

  def epg_guides_file
    "#{self.id}.json"
  end
end
