class BottomAd < ActiveRecord::Base

  include ImgCrop
  # attached start
  has_attached_file :cover, :styles => { :small => "458x257#", :large => "800x800>" }, :processors => [:cropper]
  validates_attachment_content_type :cover, :content_type => /\Aimage/

  validates_attachment :cover, :presence => true,
                        :size => { :in => 0..100.kilobytes, message: "请选择小于100k的图片" }

  imag_attr :cover

end
