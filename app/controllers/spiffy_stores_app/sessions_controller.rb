module SpiffyStoresApp
  class SessionsController < ActionController::Base
    include SpiffyStoresApp::LoginProtection
    layout false, only: :new
    after_action only: [:new, :create] do |controller|
      controller.response.headers.except!('X-Frame-Options')
    end

    def new
      authenticate if sanitized_shop_name.present?
    end

    def create
      authenticate
    end

    def callback
      if auth_hash
        login_shop
        install_webhooks
        install_scripttags
        perform_after_authenticate_job

        redirect_to return_address
      else
        flash[:error] = I18n.t('could_not_log_in')
        redirect_to login_url
      end
    end

    def destroy
      reset_session
      flash[:notice] = I18n.t('.logged_out')
      redirect_to login_url
    end

    def failure
      message = "#{I18n.t('could_not_log_in')} - #{params['message']}"
      flash[:error] = message
      origin_url = params[:origin]
      redirect_url = login_url

      if origin_url
        uri = URI.parse(origin_url)
        store = URI.decode_www_form(uri.query || '').to_h['store']
        redirect_url = "https://#{store}/admin/apps?flash_error=#{message}" if store
      end

      redirect_to redirect_url
    end

    private

    def authenticate
      if sanitized_shop_name.present?
        session['spiffy.omniauth_params'] = { store: sanitized_shop_name }
        fullpage_redirect_to "#{main_app.root_path}auth/spiffy"
      else
        flash[:error] = I18n.t('invalid_shop_url')
        redirect_to return_address
      end
    end

    def login_shop
      sess = SpiffyStoresAPI::Session.new(shop_name, token)

      request.session_options[:renew] = true
      session.delete(:_csrf_token)

      session[:spiffy_stores] = SpiffyStoresApp::SessionRepository.store(sess)
      session[:spiffy_stores_domain] = shop_name
      session[:spiffy_stores_user] = associated_user if associated_user.present?
    end

    def auth_hash
      request.env['omniauth.auth']
    end

    def shop_name
      auth_hash.uid
    end

    def associated_user
      return unless auth_hash['extra'].present?
      auth_hash['extra']['associated_user']
    end

    def token
      auth_hash['credentials']['token']
    end

    def install_webhooks
      return unless SpiffyStoresApp.configuration.has_webhooks?

      WebhooksManager.queue(
        shop_name,
        token,
        SpiffyStoresApp.configuration.webhooks
      )
    end

    def install_scripttags
      return unless SpiffyStoresApp.configuration.has_scripttags?

      ScripttagsManager.queue(
        shop_name,
        token,
        SpiffyStoresApp.configuration.scripttags
      )
    end

    def perform_after_authenticate_job
      config = SpiffyStoresApp.configuration.after_authenticate_job

      return unless config && config[:job].present?

      if config[:inline] == true
        config[:job].perform_now(shop_domain: session[:spiffy_stores_domain])
      else
        config[:job].perform_later(shop_domain: session[:spiffy_stores_domain])
      end
    end

    def return_address
      session.delete(:return_to) || SpiffyStoresApp::configuration.root_url
    end
  end
end
