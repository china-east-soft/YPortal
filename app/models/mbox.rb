class Mbox < ActiveRecord::Base

  belongs_to :portal_style

  validates_uniqueness_of :appid, scope: :portal_style_id

  class << self

    def default_covers
      (%w{ 店铺介绍 商品展示 店铺活动 搜周边 }.zip(%w{ tu_01_07.png tu_01_10.png tu_01_15.png tu_01_22.png})).to_h
    end

  end

  def detail_url
    case self.category
    when '店铺介绍'
      'wifi_welcome_url'
    when '商品展示'
      'wifi_products_url'
    when '店铺活动'
      'wifi_products_url'
    when '搜周边'
      'wifi_surroundings_url'
    else
      'wifi_products_url'
    end
  end

  def default_cover
    Mbox.default_covers[self.name]
  end

end
