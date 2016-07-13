module SpiffyStoresApp
  class AuthenticatedController < ApplicationController
    before_action :login_again_if_different_shop
    around_action :spiffy_stores_session
    layout SpiffyStoresApp.configuration.embedded_app? ? 'embedded_app' : 'application'
  end
end
