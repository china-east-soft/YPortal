Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")

Rails.application.config.assets.precompile += %w(.svg .eot .woff .ttf)

Rails.application.config.assets.precompile += %w(home.css admin.css devise.css wifi.css wifi_home.css mobile.css)
Rails.application.config.assets.precompile += %w(home.js admin.js devise.js wifi.js wifi_home.js mobile.js)
