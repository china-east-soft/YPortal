class PortalStyle < ActiveRecord::Base

  belongs_to :merchant
  has_many :banners



end
