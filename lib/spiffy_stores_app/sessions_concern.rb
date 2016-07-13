module SpiffyStoresApp
  module SessionsConcern
    extend ActiveSupport::Concern

    def new
      authenticate if params[:shop].present?
    end

    def create
      authenticate
    end

    def callback
      if response = request.env['omniauth.auth']
        shop_name = response.uid
        token = response['credentials']['token']

        sess = SpiffyStoresAPI::Session.new(shop_name, token)
        session[:spiffy_stores] = SpiffyStoresApp::SessionRepository.store(sess)
        session[:spiffy_stores_domain] = shop_name

        WebhooksManager.queue(shop_name, token) if SpiffyStoresApp.configuration.has_webhooks?
        ScripttagsManager.queue(shop_name, token) if SpiffyStoresApp.configuration.has_scripttags?

        flash[:notice] = I18n.t('.logged_in')
        redirect_to_with_fallback return_address
      else
        flash[:error] = I18n.t('could_not_log_in')
        redirect_to_with_fallback login_url
      end
    end

    def destroy
      session[:spiffy_stores] = nil
      session[:spiffy_stores_domain] = nil
      flash[:notice] = I18n.t('.logged_out')
      redirect_to_with_fallback login_url
    end

    protected

    def authenticate
      if shop_name = sanitize_shop_param(params)
        fullpage_redirect_to "#{main_app.root_path}auth/spiffy_stores?shop=#{shop_name}"
      else
        redirect_to_with_fallback return_address
      end
    end

    def return_address
      session.delete(:return_to) || main_app.root_url
    end

    def sanitized_shop_name
      @sanitized_shop_name ||= sanitize_shop_param(params)
    end

    def sanitize_shop_param(params)
      return unless params[:shop].present?
      SpiffyStoresApp::Utils.sanitize_shop_domain(params[:shop])
    end

  end
end
