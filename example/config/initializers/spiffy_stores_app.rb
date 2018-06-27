SpiffyStoresApp.configure do |config|
  config.application_name = 'Example App'
  config.api_key = ENV['SPIFFY_STOREES_CLIENT_API_KEY']
  config.secret = ENV['SPIFFY_STORES_CLIENT_API_SECRET']
  config.scope = 'read_customers, read_orders, write_products'
  config.embedded_app = true
  config.session_repository = Shop
end
