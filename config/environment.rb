# Load the Rails application.
require File.expand_path('../application', __FILE__)

MACS = {}

# Initialize the Rails application.
Rails.application.initialize!

Time::DATE_FORMATS[:date] = "%Y-%m-%d %H:%M"
