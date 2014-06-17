class Landing < ActiveRecord::Base

  has_attached_file :cover
  validates_attachment_content_type :cover, :content_type => /\Aimage/

  validates_attachment :cover, :presence => true,
                        :size => { :in => 0..100.kilobytes }

  def cover_geometry style = :original
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(cover.path(style))
  end


end
