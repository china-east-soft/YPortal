class Product < ActiveRecord::Base
  belongs_to :merchant

  validates_presence_of :name, :price, :description

  include ImgCrop

  # attached start
  has_attached_file :product_photo, :styles => { :small => "458x257#", :large => "800x800>" }, :processors => [:cropper]
  validates_attachment_content_type :product_photo, :content_type => /\Aimage/

  validates_attachment :product_photo, :presence => true,
                        :size => { :in => 0..100.kilobytes }

  scope :hot, -> { where("hot >= 1").limit(2) }

  def hot?
    self.hot >= 1
  end

end
