Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")

Rails.application.config.assets.precompile += %w(.svg .eot .woff .ttf)

Rails.application.config.assets.precompile += %w( admin.css devise.css )
Rails.application.config.assets.precompile += %w( admin.js devise.js )