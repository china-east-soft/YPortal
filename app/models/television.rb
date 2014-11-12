class Television < ActiveRecord::Base
  before_save do |record|
    record.name.upcase!
  end

  validates :name, uniqueness: {case_sensitive: false}
  has_many :programs

  enum branch: [:global, :local]

  #attachment
  has_attached_file :logo
  validates_attachment_content_type :logo, :content_type => /\Aimage/
  validates_attachment :logo, :size => { :in => 0..100.kilobytes, message: "请选择小于100k的图片" }
end
