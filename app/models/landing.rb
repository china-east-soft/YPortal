class Landing < ActiveRecord::Base

  has_attached_file :cover
  validates_attachment_content_type :cover, :content_type => /\Aimage/

  validates_attachment :cover, :presence => true,
                        :size => { :in => 0..100.kilobytes }

  validates_presence_of :start_at, :end_at

  validate :end_at_must_be_bigger_than_start_at

  def end_at_must_be_bigger_than_start_at
    errors.add(:start_at, "结束日期必须大于开始日期") if
      start_at && end_at and end_at < start_at
  end

  def cover_geometry style = :original
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(cover.path(style))
  end


end
