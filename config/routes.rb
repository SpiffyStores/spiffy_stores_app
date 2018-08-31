SpiffyStoresApp::Engine.routes.draw do
  controller :sessions do
    get 'login' => :new, :as => :login
    post 'login' => :create, :as => :authenticate
    get 'auth/spiffy/callback' => :callback
    get 'auth/failure' => :failure
    get 'logout' => :destroy, :as => :logout
  end

  namespace :webhooks do
    post ':type' => :receive
  end
end
