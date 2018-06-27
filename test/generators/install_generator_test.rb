require 'test_helper'
require 'generators/spiffy_stores_app/install/install_generator'

class InstallGeneratorTest < Rails::Generators::TestCase
  tests SpiffyStoresApp::Generators::InstallGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))

  setup do
    prepare_destination
    provide_existing_application_file
    provide_existing_routes_file
    provide_existing_application_controller
  end

  test "creates the SpiffyStoresApp initializer" do
    run_generator
    assert_file "config/initializers/spiffy_stores_app.rb" do |spiffy_stores_app|
      assert_match 'config.application_name = "My Spiffy Stores App"', spiffy_stores_app
      assert_match 'config.api_key = "<api_key>"', spiffy_stores_app
      assert_match 'config.secret = "<secret>"', spiffy_stores_app
      assert_match 'config.scope = "read_orders, read_products"', spiffy_stores_app
      assert_match "config.embedded_app = true", spiffy_stores_app
      assert_match "config.after_authenticate_job = false", spiffy_stores_app
    end
  end

  test "creates the SpiffyStoresApp initializer with args" do
    run_generator %w(--application_name Test Name --api_key key --secret shhhhh --scope read_orders, write_products)
    assert_file "config/initializers/spiffy_stores_app.rb" do |spiffy_stores_app|
      assert_match 'config.application_name = "Test Name"', spiffy_stores_app
      assert_match 'config.api_key = "key"', spiffy_stores_app
      assert_match 'config.secret = "shhhhh"', spiffy_stores_app
      assert_match 'config.scope = "read_orders, write_products"', spiffy_stores_app
      assert_match 'config.embedded_app = true', spiffy_stores_app
      assert_match 'config.session_repository = SpiffyStoresApp::InMemorySessionStore', spiffy_stores_app
    end
  end

  test "creates the SpiffyStoresApp initializer with double-quoted args" do
    run_generator %w(--application_name "Test Name" --api_key key --secret shhhhh --scope "read_orders, write_products")
    assert_file "config/initializers/spiffy_stores_app.rb" do |spiffy_stores_app|
      assert_match 'config.application_name = "Test Name"', spiffy_stores_app
      assert_match 'config.api_key = "key"', spiffy_stores_app
      assert_match 'config.secret = "shhhhh"', spiffy_stores_app
      assert_match 'config.scope = "read_orders, write_products"', spiffy_stores_app
      assert_match 'config.embedded_app = true', spiffy_stores_app
      assert_match 'config.session_repository = SpiffyStoresApp::InMemorySessionStore', spiffy_stores_app
    end
  end

  test "creates the SpiffyStoresApp initializer for non embedded app" do
    run_generator %w(--embedded false)
    assert_file "config/initializers/spiffy_stores_app.rb" do |spiffy_stores_app|
      assert_match "config.embedded_app = false", spiffy_stores_app
    end
  end

  test "creats and injects into omniauth initializer" do
    run_generator
    assert_file "config/initializers/omniauth.rb" do |omniauth|
      assert_match "provider :spiffy", omniauth
    end
  end

  test "creates the embedded_app layout" do
    run_generator
    assert_file "app/views/layouts/embedded_app.html.erb"
    assert_file "app/views/layouts/_flash_messages.html.erb"
  end

  test "adds engine to routes" do
    run_generator
    assert_file "config/routes.rb" do |routes|
      assert_match "mount SpiffyStoresApp::Engine, at: '/'", routes
    end
  end
end
