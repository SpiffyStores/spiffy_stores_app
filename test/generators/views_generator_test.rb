require 'test_helper'
require 'generators/spiffy_stores_app/views/views_generator'

class ViewsGeneratorTest < Rails::Generators::TestCase
  tests SpiffyStoresApp::Generators::ViewsGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "copies SpiffyStoresApp views to the host application" do
    run_generator
    assert_directory "app/views"
    assert_file "app/views/spiffy_stores_app/sessions/new.html.erb"
  end

end
