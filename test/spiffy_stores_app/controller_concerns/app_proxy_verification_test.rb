require 'test_helper'

class AppProxyVerificationController < ActionController::Base
  self.allow_forgery_protection = true
  protect_from_forgery with: :exception

  include SpiffyStoresApp::AppProxyVerification

  def basic
    head :ok
  end
end

class AppProxyVerificationTest < ActionController::TestCase
  tests AppProxyVerificationController

  setup do
    SpiffyStoresApp.configure do |config|
      config.secret = 'secret'
    end
  end

  test 'no_signature' do
    assert_not query_string_valid? 'store=some-random-store.spiffystores.com&path_prefix=%2Fapps%2Fmy-app&timestamp=1466106083'
  end

  test 'basic_query_string' do
    assert query_string_valid? 'store=some-random-store.spiffystores.com&path_prefix=%2Fapps%2Fmy-app&timestamp=1466106083&signature=a8ffddcc6793c8dbeee695a89a280e9dadd2a288d2454886129b643ef9360cc8'
    assert_not query_string_valid? 'store=some-random-store.spiffystores.com&path_prefix=%2Fapps%2Fmy-app&timestamp=1466106083&evil=1&signature=a8ffddcc6793c8dbeee695a89a280e9dadd2a288d2454886129b643ef9360cc8'
    assert_not query_string_valid? 'store=some-random-store.spiffystores.com&path_prefix=%2Fapps%2Fmy-app&timestamp=1466106083&evil=1&signature=wrongwrong8b1c50102a6f33c0b63ad1e1072a2fc126cb58d4500f75223cefcd'
  end

  test 'query_string_complex_args' do
    assert query_string_valid? 'store=some-random-store.spiffystores.com&path_prefix=%2Fapps%2Fmy-app&timestamp=1466106083&signature=222bcd14d670335d3bacd3750bc01eb40161bb47534f5dd1372d4c8a79f6dbce&foo=bar&baz[1]&baz[2]=b&baz[c[0]]=whatup&baz[c[1]]=notmuch'
    assert query_string_valid? 'store=some-random-store.spiffystores.com&path_prefix=%2Fapps%2Fmy-app&timestamp=1466106083&foo=bar&baz[1]&baz[2]=b&baz[c[0]]=whatup&baz[c[1]]=notmuch&signature=222bcd14d670335d3bacd3750bc01eb40161bb47534f5dd1372d4c8a79f6dbce'
  end

  test 'request with invalid signature should fail with 403' do
    with_test_routes do
      invalid_params = {
        store: 'some-random-store.spiffystores.com',
        path_prefix: '/apps/my-app',
        timestamp: '1466106083',
        signature: 'wrong233558b1c50102a6f33c0b63ad1e1072a2fc126cb58d4500f75223cefcd'
      }
      get :basic, params: invalid_params
      assert_response :forbidden
    end
  end

  test 'request with a valid signature should pass' do
    with_test_routes do
      valid_params = {
        store: 'some-random-store.spiffystores.com',
        path_prefix: '/apps/my-app',
        timestamp: '1466106083',
        signature: 'a8ffddcc6793c8dbeee695a89a280e9dadd2a288d2454886129b643ef9360cc8'
      }
      get :basic, params: valid_params
      assert_response :ok
    end
  end

  private

  def query_string_valid?(query_string)
    AppProxyVerificationController.new.send(:query_string_valid?, query_string)
  end

  def with_test_routes
    with_routing do |set|
      set.draw do
        get '/app_proxy/basic' => 'app_proxy_verification#basic'
      end
      yield
    end
  end
end
