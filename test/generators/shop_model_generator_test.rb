require 'test_helper'
require 'generators/spiffy_stores_app/shop_model/shop_model_generator'

class ShopModelGeneratorTest < Rails::Generators::TestCase
  tests SpiffyStoresApp::Generators::ShopModelGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  
  setup do
    prepare_destination
    provide_existing_initializer_file
  end

  test "create the shop model" do
    run_generator
    assert_file "app/models/shop.rb" do |shop|
      assert_match "class Shop < ActiveRecord::Base", shop
      assert_match "include SpiffyStoresApp::SessionStorage", shop
    end
  end

  test "creates ShopModel migration" do
    run_generator
    assert_migration "db/migrate/create_shops.rb" do |migration|
      assert_match "create_table :shops  do |t|", migration
    end
  end

  test "updates the spiffy_stores_app initializer" do
    run_generator
    assert_file "config/initializers/spiffy_stores_app.rb" do |file|
      assert_match "config.session_repository = Shop", file
    end
  end

  test "creates default shop fixtures" do
    run_generator
    assert_file "test/fixtures/shops.yml" do |file|
      assert_match "regular_shop:", file
    end
  end

end
