if Rails.configuration.cache_classes
  SpiffyStoresApp::SessionRepository.storage = Shop
else
  ActionDispatch::Reloader.to_prepare do
    SpiffyStoresApp::SessionRepository.storage = Shop
  end
end
