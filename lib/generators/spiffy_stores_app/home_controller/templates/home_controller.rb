class HomeController < SpiffyStoresApp::AuthenticatedController
  def index
    @products = SpiffyStoresAPI::Product.find(:all, :params => {:limit => 10})
  end
end
