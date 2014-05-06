Rails.application.config.time_zone = 'Beijing'

Rails.application.config.i18n.default_locale = "zh-CN"

I18n.locale = "zh-CN"

Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'models', '*', '*.yml').to_s]  
Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'views', '*', '*.yml').to_s] 