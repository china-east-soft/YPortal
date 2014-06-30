class Banner < ActiveRecord::Base

  belongs_to :merchant

  include ImgCrop
  # attached start
  has_attached_file :cover, :styles => { :small => "458x257#", :large => "800x800>" }, :processors => [:cropper]
  validates_attachment_content_type :cover, :content_type => /\Aimage/

  validates_attachment :cover, :presence => true,
                        :size => { :in => 0..25.kilobytes }

  validates_presence_of :description

  imag_attr :cover
  
end
