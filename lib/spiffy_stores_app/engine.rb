# frozen_string_literal: true
module SpiffyStoresApp
  class Engine < Rails::Engine
    engine_name 'spiffy_stores_app'
    isolate_namespace SpiffyStoresApp

    initializer "spiffy_stores_app.assets.precompile" do |app|
      app.config.assets.precompile += %w( spiffy_stores_app/redirect.js )
    end
  end
end
