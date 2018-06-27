Rails.application.routes.draw do
  mount SpiffyStoresApp::Engine, at: '/'
  root to: 'home#index'
end
