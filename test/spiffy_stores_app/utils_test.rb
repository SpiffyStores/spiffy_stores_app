require 'test_helper'

class UtilsTest < ActiveSupport::TestCase

  setup do
    SpiffyStoresApp.configuration = nil
  end

  ['my-shop', 'my-shop.spiffystores.com', 'https://my-shop.spiffystores.com', 'http://my-shop.spiffystores.com'].each do |good_url|
    test "sanitize_shop_domain for (#{good_url})" do
      assert SpiffyStoresApp::Utils.sanitize_shop_domain(good_url)
    end
  end

  ['my-shop', 'my-shop.spiffystores.io', 'https://my-shop.spiffystores.io', 'http://my-shop.spiffystores.io'].each do |good_url|
    test "sanitize_shop_domain URL (#{good_url}) with custom spiffy_stores_domain" do
      SpiffyStoresApp.configuration.spiffy_stores_domain = 'spiffystores.io'
      assert SpiffyStoresApp::Utils.sanitize_shop_domain(good_url)
    end
  end

  ['myshop.com', 'spiffystores.com', 'spiffystores.com.au', 'two words', 'store.spiffystores.com.evil.com', '/foo/bar'].each do |bad_url|
    test "sanitize_shop_domain for a non-spiffystores URL (#{bad_url})" do
      assert_nil SpiffyStoresApp::Utils.sanitize_shop_domain(bad_url)
    end
  end
end
