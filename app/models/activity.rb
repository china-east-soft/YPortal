class Activity < ActiveRecord::Base

  belongs_to :merchant

  include ImgCrop
  # attached start
  has_attached_file :cover, :styles => { :small => "458x257#", :large => "800x800>" }, :processors => [:cropper]
  validates_attachment_content_type :cover, :content_type => /\Aimage/

  validates_attachment :cover,
                        :size => { :in => 0..500.kilobytes }

  validates_presence_of :description

  imag_attr :cover
  # attached end

  enum status: [ :init, :active, :expired ] 

  validates_presence_of :merchant_id, :title, :started_at, :end_at, :description
  validates_date :started_at, :end_at
  validates_date :end_at, :after => :started_at

  default_scope { order(("hot DESC nulls last, id DESC")) }
  #scope :actived, -> { where('status = ?', Activity.statuses[:active] ) }

  def before_update
    if Date.today < self.started_at
      self.status = Activity.statuses[:init]
    elsif Date.today >= self.started_at && Date.today <= self.end_at
      self.status = Activity.statuses[:active]
    else
      self.status = Activity.statuses[:expired]
    end
  end




end
