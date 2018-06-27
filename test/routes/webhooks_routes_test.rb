require 'test_helper'

class WebhooksRoutingTest < ActionController::TestCase
  setup do
    @routes = SpiffyStoresApp::Engine.routes
  end

  test "webhooks routing" do
    assert_routing(
      { method: 'post', path: 'webhooks/test' },
      { controller: 'spiffy_stores_app/webhooks', action: 'receive', type: 'test' }
    )
  end
end
