class AppConnection < ActiveRecord::Base
  belongs_to :app, counter_cache: true
end
