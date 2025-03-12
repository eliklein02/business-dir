# config/initializers/whatsapp_sdk.rb
require "whatsapp_sdk"

WhatsappSdk.configure do |config|
    config.access_token = ENV.fetch("ACCESS_TOKEN")
    # config.api_version = ENV.fetch("VERSION")
    config.logger = Logger.new(STDOUT) # optional, Faraday logger to attach
    config.logger_options = { bodies: true } # optional, they are all valid logger_options for Faraday
end