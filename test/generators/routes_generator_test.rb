require 'test_helper'
require 'generators/spiffy_stores_app/routes/routes_generator'

class ControllerGeneratorTest < Rails::Generators::TestCase
  tests SpiffyStoresApp::Generators::RoutesGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))

  setup do
    prepare_destination
    provide_existing_routes_file
  end

  test "copies SpiffyStoresApp routes to the host application" do
    run_generator

    assert_file "config/routes.rb" do |routes|
      assert_match "get 'login' => :new, :as => :login", routes
      assert_match "post 'login' => :create, :as => :authenticate", routes
      assert_match "get 'auth/spiffy/callback' => :callback", routes
      assert_match "get 'logout' => :destroy, :as => :logout", routes
      refute_match "mount SpiffyStoresApp::Engine, at: '/'", routes
    end
  end

end
