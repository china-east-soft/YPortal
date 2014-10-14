class BottomAd < ActiveRecord::Base

  scope :current_ad, -> { where("(start_at <= ? and end_at >= ?) or start_at >= ?", Date.today.beginning_of_day, Date.today.end_of_day, Date.today.end_of_day).order("start_at desc") }

  include ImgCrop
  # attached start
  has_attached_file :cover, :styles => { :small => "458x257#", :large => "800x800>" }, :processors => [:cropper]
  validates_attachment_content_type :cover, :content_type => /\Aimage/

  validates_attachment :cover, :presence => true,
                        :size => { :in => 0..100.kilobytes, message: "请选择小于100k的图片" }

  imag_attr :cover

  validates_presence_of :start_at, :end_at

  validate :end_at_must_be_bigger_than_start_at

  def end_at_must_be_bigger_than_start_at
    errors.add(:start_at, "结束日期必须大于开始日期") if
      start_at && end_at and end_at < start_at
  end

end
