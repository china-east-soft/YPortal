class PortalStyle < ActiveRecord::Base

  belongs_to :merchant
  has_many :banners, dependent: :destroy
  has_many :mboxes, -> { order "appid ASC" }, dependent: :destroy

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
