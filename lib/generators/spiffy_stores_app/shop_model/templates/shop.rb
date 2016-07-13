class Shop < ActiveRecord::Base
  include SpiffyStoresApp::Shop
  include SpiffyStoresApp::SessionStorage
end
