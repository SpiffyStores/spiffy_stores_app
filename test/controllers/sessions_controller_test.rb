require 'test_helper'

module SpiffyStores
  class AfterAuthenticateJob < ActiveJob::Base
    def perform; end
  end
end

module SpiffyStoresApp
  class SessionsControllerTest < ActionController::TestCase

    setup do
      @routes = SpiffyStoresApp::Engine.routes
      SpiffyStoresApp::SessionRepository.storage = SpiffyStoresApp::InMemorySessionStore
      SpiffyStoresApp.configuration = nil

      I18n.locale = :en
    end

    test "#new should authenticate the shop if a valid store param exists" do
      spiffy_stores_domain = 'my-shop.spiffystores.com'
      get :new, params: { store: 'my-shop' }
      assert_redirected_to_authentication(spiffy_stores_domain, response)
    end

    test "#new should authenticate the shop if a valid store param exists non embedded" do
      SpiffyStoresApp.configuration.embedded_app = false
      get :new, params: { store: 'my-shop' }
      assert_redirected_to '/auth/spiffy'
      assert_equal session['spiffy.omniauth_params'][:store], 'my-shop.spiffystores.com'
    end

    test "#new should trust the store param over the current session" do
      previously_logged_in_shop_id = 1
      session[:spiffy_stores] = previously_logged_in_shop_id
      new_shop_domain = "new-shop.spiffystores.com"
      get :new, params: { store: new_shop_domain }
      assert_redirected_to_authentication(new_shop_domain, response)
    end

    test "#new should render a full-page if the store param doesn't exist" do
      get :new
      assert_response :ok
      assert_match %r{Spiffy Stores App — Installation}, response.body
    end

    test "#new should render a full-page if the store param value is not a shop" do
      non_shop_address = "example.com"
      get :new, params: { store: non_shop_address }
      assert_response :ok
      assert_match %r{Spiffy Stores App — Installation}, response.body
    end

    ['my-shop', 'my-shop.spiffystores.com', 'https://my-shop.spiffystores.com', 'http://my-shop.spiffystores.com'].each do |good_url|
      test "#create should authenticate the shop for the URL (#{good_url})" do
        spiffy_stores_domain = 'my-shop.spiffystores.com'
        post :create, params: { store: good_url }
        assert_redirected_to_authentication(spiffy_stores_domain, response)
      end
    end

    ['my-shop', 'my-shop.spiffystores.io', 'https://my-shop.spiffystores.io', 'http://my-shop.spiffystores.io'].each do |good_url|
      test "#create should authenticate the shop for the URL (#{good_url}) with custom spiffy_stores_domain" do
        SpiffyStoresApp.configuration.spiffy_stores_domain = 'spiffystores.io'
        spiffy_stores_domain = 'my-shop.spiffystores.io'
        post :create, params: { store: good_url }
        assert_redirected_to_authentication(spiffy_stores_domain, response)
      end
    end

    ['myshop.com', 'spiffystores.com', 'spiffystores.com.au', 'two words', 'store.spiffystores.com.evil.com', '/foo/bar'].each do |bad_url|
      test "#create should return an error for a non-spiffystores URL (#{bad_url})" do
        post :create, params: { store: bad_url }
        assert_response :redirect
        assert_redirected_to '/'
        assert_equal I18n.t('invalid_shop_url'), flash[:error]
      end
    end

    test "#create should render the login page if the shop param doesn't exist" do
      post :create
      assert_redirected_to '/'
    end

    test '#callback should flash error when omniauth is not present' do
      get :callback, params: { store: 'shop' }
      assert_equal flash[:error], 'Could not log in to Spiffy Stores store'
    end

    test '#callback should flash error in Spanish' do
      I18n.locale = :es
      get :callback, params: { store: 'shop' }
      assert_equal flash[:error], 'No se pudo iniciar sesión en tu tienda de Spiffy Stores'
    end

    test "#callback should setup a spiffy_stores session" do
      mock_spiffy_omniauth

      get :callback, params: { store: 'shop' }
      assert_not_nil session[:spiffy_stores]
      assert_equal 'shop.spiffystores.com', session[:spiffy_stores_domain]
    end

    test "#callback should setup a spiffy_stores session with a user for online mode" do
      mock_spiffy_user_omniauth

      get :callback, params: { store: 'shop' }
      assert_not_nil session[:spiffy_stores]
      assert_equal 'shop.spiffystores.com', session[:spiffy_stores_domain]
      assert_equal 'user_object', session[:spiffy_stores_user]
    end

    test "#callback should start the WebhooksManager if webhooks are configured" do
      SpiffyStoresApp.configure do |config|
        config.webhooks = [{topic: 'carts/update', address: 'example-app.com/webhooks'}]
      end

      SpiffyStoresApp::WebhooksManager.expects(:queue)

      mock_spiffy_omniauth
      get :callback, params: { store: 'shop' }
    end

    test "#callback doesn't run the WebhooksManager if no webhooks are configured" do
      SpiffyStoresApp.configure do |config|
        config.webhooks = []
      end

      SpiffyStoresApp::WebhooksManager.expects(:queue).never

      mock_spiffy_omniauth
      get :callback, params: { store: 'shop' }
    end

    test "#destroy should clear spiffy_stores from session and redirect to login with notice" do
      shop_id = 1
      session[:spiffy_stores] = shop_id
      session[:spiffy_stores_domain] = 'shop1.spiffystores.com'
      session[:spiffy_stores_user] = { 'id' => 1, 'email' => 'foo@example.com' }

      get :destroy

      assert_nil session[:spiffy_stores]
      assert_nil session[:spiffy_stores_domain]
      assert_nil session[:spiffy_stores_user]
      assert_redirected_to login_path
      assert_equal 'Successfully logged out', flash[:notice]
    end

    test '#destroy should redirect with notice in spanish' do
      I18n.locale = :es
      shop_id = 1
      session[:spiffy_stores] = shop_id
      session[:spiffy_stores_domain] = 'shop1.spiffystores.com'

      get :destroy

      assert_equal 'Cerrar sesión', flash[:notice]
    end

    test "#callback calls #perform_after_authenticate_job and performs inline when inline is true" do
      SpiffyStoresApp.configure do |config|
        config.after_authenticate_job = { job: SpiffyStores::AfterAuthenticateJob, inline: true }
      end

      SpiffyStores::AfterAuthenticateJob.expects(:perform_now)

      mock_spiffy_omniauth
      get :callback, params: { store: 'shop' }
    end

    test "#callback calls #perform_after_authenticate_job and performs asynchronous when inline isn't true" do
      SpiffyStoresApp.configure do |config|
        config.after_authenticate_job = { job: SpiffyStores::AfterAuthenticateJob, inline: false }
      end

      SpiffyStores::AfterAuthenticateJob.expects(:perform_later)

      mock_spiffy_omniauth
      get :callback, params: { store: 'shop' }
    end

    test "#callback doesn't call #perform_after_authenticate_job if job is nil" do
      SpiffyStoresApp.configure do |config|
        config.after_authenticate_job = { job: nil, inline: false }
      end

      SpiffyStores::AfterAuthenticateJob.expects(:perform_later).never

      mock_spiffy_omniauth
      get :callback, params: { store: 'shop' }
    end

    test "#callback calls #perform_after_authenticate_job and performs async if inline isn't present" do
      SpiffyStoresApp.configure do |config|
        config.after_authenticate_job = { job: SpiffyStores::AfterAuthenticateJob }
      end

      SpiffyStores::AfterAuthenticateJob.expects(:perform_later)

      mock_spiffy_omniauth
      get :callback, params: { store: 'shop' }
    end

    private

    def mock_spiffy_omniauth
      OmniAuth.config.add_mock(:spiffy, provider: :spiffy, uid: 'shop.spiffystores.com', credentials: {token: '1234'})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:spiffy] if request
      request.env['omniauth.params'] = { store: 'shop.spiffystores.com' } if request
    end

    def mock_spiffy_user_omniauth
      OmniAuth.config.add_mock(:spiffy,
        provider: :spiffy,
        uid: 'shop.spiffystores.com',
        credentials: {token: '1234'},
        extra: {associated_user: 'user_object'}
      )
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:spiffy] if request
      request.env['omniauth.params'] = { store: 'shop.spiffystores.com' } if request
    end

    def assert_redirected_to_authentication(shop_domain, response)
      auth_url = "/auth/spiffy"

      assert_template 'shared/redirect'
      assert_select '[id=redirection-target]', 1 do |elements|
        assert_equal "{\"myspiffyUrl\":\"https://#{shop_domain}\",\"url\":\"#{auth_url}\"}",
          elements.first['data-target']
      end
    end
  end
end
