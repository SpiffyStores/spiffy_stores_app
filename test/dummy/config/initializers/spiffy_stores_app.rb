class SpiffyStoresAppConfigurer
  def self.call
    SpiffyStoresApp.configure do |config|
      config.api_key = "key"
      config.secret = "secret"
      config.scope = 'read_orders, read_products'
      config.embedded_app = true
      config.spiffy_stores_domain = 'spiffystores.com'
    end
  end
end

SpiffyStoresAppConfigurer.call
