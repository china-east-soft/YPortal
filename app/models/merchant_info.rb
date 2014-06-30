class MerchantInfo < ActiveRecord::Base

  belongs_to :merchant
  attr_accessor :validate_base_info
  attr_accessor :validate_shop_info

  validates_presence_of :name, :contact_person_name, :contact_way, if: "validate_base_info"

  #detailed infomation
  include ImgCrop

  # attached start
  has_attached_file :shop_photo, :styles => { :small => "458x257#", :large => "800x800>" }, :processors => [:cropper]
  validates_attachment_content_type :shop_photo, :content_type => /\Aimage/

  validates_attachment :shop_photo, :presence => true,
                        :size => { :in => 0..500.kilobytes }, if: "validate_shop_info"
  validates_presence_of :shop_description, :shop_phone_one, :shop_longitude, :shop_latitude, :province, :city, :area, :address, if: :"validate_shop_info"

  imag_attr :shop_photo

  # geocode
  geocoded_by :address, :latitude  => :shop_latitude, :longitude => :shop_longitude # ActiveRecord

end
