# frozen_string_literal: true
class HomeController < SpiffyStoresApp::AuthenticatedController
  def index
    @products = SpiffyStoresAPI::Product.find(:all, params: { limit: 10 })
    @webhooks = SpiffyStoresAPI::Webhook.find(:all)
  end
end
