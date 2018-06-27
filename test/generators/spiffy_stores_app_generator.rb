require 'test_helper'
require 'generators/spiffy_stores_app/spiffy_stores_app_generator'

class SpiffyStoresAppGeneratorTest < Rails::Generators::TestCase
  tests SpiffyStoresApp::Generators::SpiffyStoresAppGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "spiffy_stores_app_generator runs" do
    run_generator
  end
end
