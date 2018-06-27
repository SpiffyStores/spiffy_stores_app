require 'test_helper'

class SessionsRoutesTest < ActionController::TestCase
  setup do
    @routes = SpiffyStoresApp::Engine.routes
    SpiffyStoresApp::SessionRepository.storage = SpiffyStoresApp::InMemorySessionStore
    SpiffyStoresApp.configuration = nil
  end

  test "login routes to sessions#new" do
    assert_routing '/login', { controller: 'spiffy_stores_app/sessions', action: "new" }
  end

  test "post login routes to sessions#create" do
    assert_routing({method: 'post', path: '/login'}, { controller: 'spiffy_stores_app/sessions', action: "create" })
  end

  test "auth_spiffy_callback routes to sessions#callback" do
    assert_routing '/auth/spiffy/callback', { controller: 'spiffy_stores_app/sessions', action: "callback" }
  end

  test "logout routes to sessions#destroy" do
    assert_routing '/logout', { controller: 'spiffy_stores_app/sessions', action: "destroy" }
  end
end
