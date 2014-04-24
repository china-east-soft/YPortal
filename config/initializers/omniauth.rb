require 'omniauth'
Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :weibo, '1978227561', '0ed6b8b5c2f4f2c3662ea064128198d4'
  #provider :qq_connect, '100563710', '612c2dcc74c9b61528182ac49eeb36f3'
end