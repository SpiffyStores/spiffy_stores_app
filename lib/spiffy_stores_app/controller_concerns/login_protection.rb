module SpiffyStoresApp
  module LoginProtection
    extend ActiveSupport::Concern

    class SpiffyStoresDomainNotFound < StandardError; end

    included do
      rescue_from ActiveResource::UnauthorizedAccess, :with => :close_session
    end

    def spiffy_stores_session
      if shop_session
        begin
          SpiffyStoresAPI::Base.activate_session(shop_session)
          yield
        ensure
          SpiffyStoresAPI::Base.clear_session
        end
      else
        redirect_to_login
      end
    end

    def shop_session
      return unless session[:spiffy_stores]
      @shop_session ||= SpiffyStoresApp::SessionRepository.retrieve(session[:spiffy_stores])
    end

    def login_again_if_different_shop
      if shop_session && params[:store] && params[:store].is_a?(String) && shop_session.url != params[:store]
        clear_shop_session
        redirect_to_login
      end
    end

    protected

    def redirect_to_login
      if request.xhr?
        head :unauthorized
      else
        if request.get?
          session[:return_to] = "#{request.path}?#{sanitized_params.to_query}"
        end
        redirect_to login_url
      end
    end

    def close_session
      clear_shop_session
      redirect_to login_url
    end

    def clear_shop_session
      session[:spiffy_stores] = nil
      session[:spiffy_stores_domain] = nil
      session[:spiffy_stores_user] = nil
    end

    def login_url
      url = SpiffyStoresApp.configuration.login_url

      if params[:store].present?
        query = { store: sanitized_params[:store] }.to_query
        url = "#{url}?#{query}"
      end

      url
    end

    def fullpage_redirect_to(url)
      if SpiffyStoresApp.configuration.embedded_app?
        render 'spiffy_stores_app/shared/redirect', layout: false, locals: { url: url, current_spiffy_stores_domain: current_spiffy_stores_domain }
      else
        redirect_to url
      end
    end

    def current_spiffy_stores_domain
      spiffy_stores_domain = sanitized_shop_name || session[:spiffy_stores_domain]
      return spiffy_stores_domain if spiffy_stores_domain.present?

      raise SpiffyStoresDomainNotFound
    end

    def sanitized_shop_name
      @sanitized_shop_name ||= sanitize_shop_param(params)
    end

    def sanitize_shop_param(params)
      return unless params[:store].present?
      SpiffyStoresApp::Utils.sanitize_shop_domain(params[:store])
    end

    def sanitized_params
      request.query_parameters.clone.tap do |query_params|
        if params[:store].is_a?(String)
          query_params[:store] = sanitize_shop_param(params)
        end
      end
    end
  end
end
