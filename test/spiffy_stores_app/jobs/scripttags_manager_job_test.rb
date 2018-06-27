require 'test_helper'

class SpiffyStoresApp::ScripttagsManagerJobTest < ActiveSupport::TestCase
  test "#perform creates scripttags" do
    token = 'token'
    domain = 'example-app.com'

    SpiffyStoresAPI::Session.expects(:temp).with(domain, token).yields

    manager = mock('manager')
    manager.expects(:create_scripttags)
    SpiffyStoresApp::ScripttagsManager.expects(:new).with([], domain).returns(manager)

    job = SpiffyStoresApp::ScripttagsManagerJob.new
    job.perform(shop_domain: domain, shop_token: token, scripttags: [])
  end
end
