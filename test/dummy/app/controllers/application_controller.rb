class ApplicationController < ActionController::Base
  include SpiffyStoresApp::LoginProtection
end
