  provider :spiffy,
           SpiffyStoresApp.configuration.api_key,
           SpiffyStoresApp.configuration.secret,
           scope: SpiffyStoresApp.configuration.scope,
           setup: lambda { |env|
             strategy = env['omniauth.strategy']

             spiffy_auth_params = strategy.session['spiffy.omniauth_params']&.with_indifferent_access
             store = if spiffy_auth_params.present?
               "https://#{spiffy_auth_params[:store]}"
             else
               ''
             end

             strategy.options[:client_options][:site] = store
           }
