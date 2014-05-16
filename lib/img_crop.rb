module ImgCrop

  def self.included(base)
    base.class_eval do
      attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
    end
    base.extend(ClassMethods)
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  module ClassMethods
    def imag_attr *attributes
      attributes.each do |attr|
        define_method "#{attr}_geometry" do |style = :original|
          eval %{
            @geometry ||= {}
            @geometry[style] ||= Paperclip::Geometry.from_file(#{attr}.path(style))
          }
        end
      end
    end
  end

end