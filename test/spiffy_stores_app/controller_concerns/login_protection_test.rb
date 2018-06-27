require 'test_helper'
require 'action_controller'
require 'action_controller/base'
require 'action_view/testing/resolvers'

class LoginProtectionController < ActionController::Base
  include SpiffyStoresApp::EmbeddedApp
  include SpiffyStoresApp::LoginProtection
  helper_method :shop_session

  around_action :spiffy_stores_session, only: [:index]
  before_action :login_again_if_different_shop, only: [:second_login]

  def index
    render plain: "OK"
  end

  def second_login
    render plain: "OK"
  end

  def redirect
    fullpage_redirect_to("https://example.com")
  end

  def raise_unauthorized
    raise ActiveResource::UnauthorizedAccess.new('unauthorized')
  end
end

class LoginProtectionTest < ActionController::TestCase
  tests LoginProtectionController

  setup do
    SpiffyStoresApp::SessionRepository.storage = SpiffyStoresApp::InMemorySessionStore
  end

  test "#shop_session returns nil when session is nil" do
    with_application_test_routes do
      session[:spiffy_stores] = nil
      get :index
      assert_nil @controller.shop_session
    end
  end

  test "#shop_session retreives the session from storage" do
    with_application_test_routes do
      session[:spiffy_stores] = "foobar"
      get :index
      SpiffyStoresApp::SessionRepository.expects(:retrieve).returns(session).once
      assert @controller.shop_session
    end
  end

  test "#shop_session is memoized and does not retreive session twice" do
    with_application_test_routes do
      session[:spiffy_stores] = "foobar"
      get :index
      SpiffyStoresApp::SessionRepository.expects(:retrieve).returns(session).once
      assert @controller.shop_session
      assert @controller.shop_session
    end
  end

  test "#login_again_if_different_shop removes current session and redirects to login url" do
    with_application_test_routes do
      session[:spiffy_stores] = "foobar"
      session[:spiffy_stores_domain] = "foobar"
      session[:spiffy_stores_user] = { 'id' => 1, 'email' => 'foo@example.com' }
      sess = stub(url: 'https://foobar.spiffystores.com')
      SpiffyStoresApp::SessionRepository.expects(:retrieve).returns(sess).once
      get :second_login, params: { store: 'other-shop' }
      assert_redirected_to '/login?store=other-shop.spiffystores.com'
      assert_nil session[:spiffy_stores]
      assert_nil session[:spiffy_stores_domain]
      assert_nil session[:spiffy_stores_user]
    end
  end

  test "#login_again_if_different_shop ignores non-String store params so that Rails params for Shop model can be accepted" do
    with_application_test_routes do
      session[:spiffy_stores] = "foobar"
      session[:spiffy_stores_domain] = "foobar"
      sess = stub(url: 'https://foobar.spiffystores.com')
      SpiffyStoresApp::SessionRepository.expects(:retrieve).returns(sess).once

      get :second_login, params: { store: { id: 123, disabled: true } }
      assert_response :ok
    end
  end

  test '#spiffy_stores_session with no Spiffy Stores session, redirects to the login url' do
    with_application_test_routes do
      get :index, params: { store: 'foobar' }
      assert_redirected_to '/login?store=foobar.spiffystores.com'
    end
  end

  test '#spiffy_stores_session with no Spiffy Stores session, redirects to the login url \
        with non-String store param' do
    with_application_test_routes do
      params = { store: { id: 123 } }
      get :index, params: params
      assert_redirected_to "/login?#{params.to_query}"
    end
  end

  test '#spiffy_stores_session with no Spiffy Stores session, sets session[:return_to]' do
    with_application_test_routes do
      get :index, params: { store: 'foobar' }
      assert_equal '/?store=foobar.spiffystores.com', session[:return_to]
    end
  end

  test '#spiffy_stores_session with no Spiffy Stores session, sets session[:return_to]\
        with non-String store param' do
    with_application_test_routes do
      params = { store: { id: 123 } }
      get :index, params: params
      assert_equal "/?#{params.to_query}", session[:return_to]
    end
  end

  test '#spiffy_stores_session with no Spiffy Stores session, when the request is an XHR, returns an HTTP 401' do
    with_application_test_routes do
      get :index, params: { store: 'foobar' }, xhr: true
      assert_equal 401, response.status
    end
  end

  test '#spiffy_stores_session when rescuing from unauthorized access, redirects to the login url' do
    with_application_test_routes do
      get :raise_unauthorized, params: { store: 'foobar' }
      assert_redirected_to '/login?store=foobar.spiffystores.com'
    end
  end

  test '#spiffy_stores_session when rescuing from unauthorized access, clears shop session' do
    with_application_test_routes do
      session[:spiffy_stores] = 'foobar'
      session[:spiffy_stores_domain] = 'foobar'
      session[:spiffy_stores_user] = { 'id' => 1, 'email' => 'foo@example.com' }

      get :raise_unauthorized, params: { store: 'foobar' }

      assert_nil session[:spiffy_stores]
      assert_nil session[:spiffy_stores_domain]
      assert_nil session[:spiffy_stores_user]
    end
  end

  test '#fullpage_redirect_to sends a post message to that shop in the store param' do
    with_application_test_routes do
      example_shop = 'shop.spiffystores.com'
      get :redirect, params: { store: example_shop }
      assert_fullpage_redirected(example_shop, response)
    end
  end

  test '#fullpage_redirect_to, when the store params is missing, sends a post message to the shop in the session' do
    with_application_test_routes do
      example_shop = 'shop.spiffystores.com'
      session[:spiffy_stores_domain] = example_shop
      get :redirect
      assert_fullpage_redirected(example_shop, response)
    end
  end

  test '#fullpage_redirect_to raises an exception when no Spiffy Stores domains are available' do
    with_application_test_routes do
      session[:spiffy_stores_domain] = nil
      assert_raise SpiffyStoresApp::LoginProtection::SpiffyStoresDomainNotFound do
        get :redirect
      end
    end
  end

  test '#fullpage_redirect_to skips rendering layout' do
    with_application_test_routes do
      example_shop = 'shop.spiffystores.com'
      get :redirect, params: { store: example_shop }
      rendered_templates = @_templates.keys
      assert_equal(['spiffy_stores_app/shared/redirect'], rendered_templates)
    end
  end

  test '#fullpage_redirect_to, when not an embedded app, does a regular redirect' do
    SpiffyStoresApp.configuration.embedded_app = false

    with_application_test_routes do
      get :redirect
      assert_redirected_to 'https://example.com'
    end
  end

  private

  def assert_fullpage_redirected(shop_domain, response)
    example_url = "https://example.com"

    assert_template 'shared/redirect'
    assert_select '[id=redirection-target]', 1 do |elements|
      assert_equal "{\"myspiffyUrl\":\"https://#{shop_domain}\",\"url\":\"#{example_url}\"}",
        elements.first['data-target']
    end
  end

  def with_application_test_routes
    with_routing do |set|
      set.draw do
        get '/' => 'login_protection#index'
        get '/second_login' => 'login_protection#second_login'
        get '/redirect' => 'login_protection#redirect'
        get '/raise_unauthorized' => 'login_protection#raise_unauthorized'
      end
      yield
    end
  end
end
