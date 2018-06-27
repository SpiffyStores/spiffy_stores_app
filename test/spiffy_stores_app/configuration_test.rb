require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase

  setup do
    SpiffyStoresApp.configuration = nil
  end

  test "configure" do
    SpiffyStoresApp.configure do |config|
      config.embedded_app = true
    end

    assert_equal true, SpiffyStoresApp.configuration.embedded_app
  end

  test "defaults to spiffy_stores_domain" do
    assert_equal "spiffystores.com", SpiffyStoresApp.configuration.spiffy_stores_domain
  end

  test "can set spiffy_stores_domain" do
    SpiffyStoresApp.configure do |config|
      config.spiffy_stores_domain = 'spiffystores.io'
    end

    assert_equal "spiffystores.io", SpiffyStoresApp.configuration.spiffy_stores_domain
  end

  test "can configure webhooks for creation" do
    webhook = {topic: 'carts/update', address: 'example-app.com/webhooks', format: 'json'}

    SpiffyStoresApp.configure do |config|
      config.webhooks = [webhook]
    end

    assert_equal webhook, SpiffyStoresApp.configuration.webhooks.first
  end

  test "has_webhooks? is true if webhooks have been configured" do
    refute SpiffyStoresApp.configuration.has_webhooks?

    SpiffyStoresApp.configure do |config|
      config.webhooks = [{topic: 'carts/update', address: 'example-app.com/webhooks', format: 'json'}]
    end

    assert SpiffyStoresApp.configuration.has_webhooks?
  end

end
