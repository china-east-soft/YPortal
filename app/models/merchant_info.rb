class MerchantInfo < ActiveRecord::Base

  belongs_to :merchant
  validates_presence_of :name, :industry, :address, :contact_person_name, :contact_way

end
