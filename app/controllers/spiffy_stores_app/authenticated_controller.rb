module SpiffyStoresApp
  class AuthenticatedController < ActionController::Base
    include SpiffyStoresApp::Localization
    include SpiffyStoresApp::LoginProtection
    include SpiffyStoresApp::EmbeddedApp

    protect_from_forgery with: :exception
    before_action :login_again_if_different_shop
    around_action :spiffy_stores_session
  end
end
