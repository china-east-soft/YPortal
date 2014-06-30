class PortalStyle < ActiveRecord::Base

  belongs_to :merchant
  has_many :mboxes, -> { order "appid ASC" }, dependent: :destroy
  has_many :valid_mboxes, -> { where("status = 1").order("appid ASC") }, class_name: "Mbox"
  has_many :deleted_mboxes, -> { where("status = 0").order("appid ASC") }, class_name: "Mbox"
  validates_uniqueness_of :layout, scope: :merchant_id

  after_create :init_mboxes

  def init_mboxes

    %w{ 店铺介绍 商品展示 店铺活动 搜周边 }.each_with_index do |m,mindex|
      Mbox.create(name: m, 
                  appid: mindex + 1,
                  portal_style_id: self.id,
                  category: m)
    end

  end

end
