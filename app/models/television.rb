class Television < ActiveRecord::Base
  before_save do |record|
    record.name.upcase!
  end

  after_update :update_programs_branch

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  has_many :programs, dependent: :destroy
  has_many :comments, through: :programs

  #attachment
  has_attached_file :logo
  validates_attachment_content_type :logo, :content_type => /\Aimage/
  validates_attachment :logo, :size => { :in => 0..100.kilobytes, message: "请选择小于100k的图片" }

  def parent_comments_in_4_hour_for_app(id: 0, limit: 20)
    comments = []
    programs.each do |p|
      comments += p.parent_comments_in_4_hour_for_app(id: id, limit: limit)
    end
    comments
  end

  def guides
    @guides ||= if File.exist?("#{Rails.root.to_s}/public/guides/#{id}.json")
                  File.open("#{Rails.root.to_s}/public/guides/#{id}.json", 'r') do |f|
                    JSON.parse(f.read)
                  end
                end
  end

  private
  def update_programs_branch
    puts branch
    if branch_changed?
      puts "changed"
      programs.update_all(branch: branch)
    else
      puts "not change"
    end
  end
end
