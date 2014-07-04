class Landing < ActiveRecord::Base

  include ImgCrop
  #为了适配不同机型 一个广告有多个不同分辨率的附件图像
  has_attached_file :cover_iphone, styles: {original: "320x480>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false
  has_attached_file :cover_iphone2x, styles: {original: "640x960>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false
  has_attached_file :cover_iphone586, styles: {original: "640x1136>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false
  has_attached_file :cover_andriod, styles: {original: "1280x720>"},  :default_url => "/images/:style/missing.png", :use_timestamp => false

  imag_attr :cover_iphone, :cover_iphone2x, :cover_iphone586, :cover_andriod


  validates_attachment_content_type :cover_iphone, :content_type => /\Aimage/
  validates_attachment_content_type :cover_iphone2x, :content_type => /\Aimage/
  validates_attachment_content_type :cover_iphone586, :content_type => /\Aimage/
  validates_attachment_content_type :cover_andriod, :content_type => /\Aimage/

  validates_attachment :cover_iphone, :presence => true, :size => { :in => 0..100.kilobytes }
  validates_attachment :cover_iphone2x, :presence => true, :size => { :in => 0..100.kilobytes }
  validates_attachment :cover_iphone586, :presence => true, :size => { :in => 0..100.kilobytes }
  validates_attachment :cover_andriod, :presence => true, :size => { :in => 0..100.kilobytes }

  validates_presence_of :start_at, :end_at

  validate :end_at_must_be_bigger_than_start_at

  def end_at_must_be_bigger_than_start_at
    errors.add(:start_at, "结束日期必须大于开始日期") if
      start_at && end_at and end_at < start_at
  end

  # def cover_geometry style = :original
  #   @geometry ||= {}
  #   @geometry[style] ||= Paperclip::Geometry.from_file(cover.path(style))
  # end


end
