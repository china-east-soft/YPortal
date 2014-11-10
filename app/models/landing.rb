class Landing < ActiveRecord::Base
  scope :current_landing, -> {where("(start_at <= ? and end_at >= ?) or start_at >= ?", Date.today.beginning_of_day, Date.today.end_of_day, Date.today.end_of_day).order("start_at desc") }

  include ImgCrop
  #为了适配不同机型 一个广告有多个不同分辨率的附件图像
  has_attached_file :cover_iphone, styles: {original: "320x480>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false
  has_attached_file :cover_iphone2x, styles: {original: "640x960>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false
  has_attached_file :cover_iphone586, styles: {original: "640x1136>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false
  has_attached_file :cover_andriod, styles: {original: "1280x720>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false

  #pad
  has_attached_file :cover_ipad, styles: {original: "1024x768>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false
  has_attached_file :cover_ipad_retina, styles: {original: "2048x1536>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false

  imag_attr :cover_iphone, :cover_iphone2x, :cover_iphone586, :cover_andriod, :cover_ipad, :cover_ipad_retina


  #phone
  validates_attachment_content_type :cover_iphone, :content_type => /\Aimage/
  validates_attachment_content_type :cover_iphone2x, :content_type => /\Aimage/
  validates_attachment_content_type :cover_iphone586, :content_type => /\Aimage/
  validates_attachment_content_type :cover_andriod, :content_type => /\Aimage/

  #ipad
  validates_attachment_content_type :cover_ipad, :content_type => /\Aimage/
  validates_attachment_content_type :cover_ipad_retina, :content_type => /\Aimage/

  validates_attachment :cover_iphone, :presence => true, :size => { :in => 0..200.kilobytes }
  validates_attachment :cover_iphone2x, :presence => true, :size => { :in => 0..200.kilobytes }
  validates_attachment :cover_iphone586, :presence => true, :size => { :in => 0..200.kilobytes }
  validates_attachment :cover_andriod, :presence => true, :size => { :in => 0..200.kilobytes }

  validates_attachment :cover_ipad, :presence => true, :size => { :in => 0..200.kilobytes }
  validates_attachment :cover_ipad_retina, :presence => true, :size => { :in => 0..200.kilobytes }

  validates_presence_of :start_at, :end_at

  validate :end_at_must_be_bigger_than_start_at

  def end_at_must_be_bigger_than_start_at
    errors.add(:start_at, "结束日期必须大于开始日期") if
      start_at && end_at and end_at < start_at
  end

  def self.date_must_be_exclusive(item)
    Landing.where.not(id: item.id).each do |b|
      unless (item.end_at < b.start_at || item.start_at > b.end_at)
        return false
      end
    end

    true
  end

  # def cover_geometry style = :original
  #   @geometry ||= {}
  #   @geometry[style] ||= Paperclip::Geometry.from_file(cover.path(style))
  # end


end
