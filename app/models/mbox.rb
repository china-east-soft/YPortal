class Mbox < ActiveRecord::Base

  belongs_to :portal_style

  validates_uniqueness_of :appid, scope: :portal_style_id

  class << self

    def default_covers
      (%w{ 店铺介绍 商品展示 店铺活动 搜周边 }.zip(%w{ tu_01_07.png tu_01_10.png tu_01_15.png tu_01_22.png})).to_h
    end

  end

  def default_cover
    Mbox.default_covers[self.name]
  end

end
