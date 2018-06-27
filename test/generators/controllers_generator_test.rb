require 'test_helper'
require 'generators/spiffy_stores_app/controllers/controllers_generator'

class ControllersGeneratorTest < Rails::Generators::TestCase
  tests SpiffyStoresApp::Generators::ControllersGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "copies SpiffyStoresApp controllers to the host application" do
    run_generator
    assert_directory "app/controllers"
    assert_file "app/controllers/spiffy_stores_app/sessions_controller.rb"
    assert_file "app/controllers/spiffy_stores_app/authenticated_controller.rb"
  end

end
