module SpiffyStoresApp
  module LoginProtection
    extend ActiveSupport::Concern

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
      if shop_session && params[:shop] && params[:shop].is_a?(String) && shop_session.url != params[:shop]
        session[:spiffy_stores] = nil
        session[:spiffy_stores_domain] = nil
        redirect_to_login
      end
    end

    protected

    def redirect_to_login
      if request.xhr?
        head :unauthorized
      else
        session[:return_to] = request.fullpath if request.get?
        redirect_to_with_fallback main_or_engine_login_url(shop: params[:shop])
      end
    end

    def close_session
      session[:spiffy_stores] = nil
      session[:spiffy_stores_domain] = nil
      redirect_to_with_fallback main_or_engine_login_url(shop: params[:shop])
    end

    def main_or_engine_login_url(params = {})
      main_app.login_url(params)
    rescue NoMethodError => e
      spiffy_stores_app.login_url(params)
    end

    def redirect_to_with_fallback(url)
      url_json = url.to_json
      url_json_no_quotes = url_json.gsub(/\A"|"\Z/, '')

      render inline: %Q(
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <title>Redirecting…</title>
            <script type="text/javascript">
              window.location.href = #{url_json};
            </script>
          </head>
          <body>
          </body>
        </html>
      ), status: 302, location: url
    end

    def fullpage_redirect_to(url)
      url_json = url.to_json
      url_json_no_quotes = url_json.gsub(/\A"|"\Z/, '')

      if SpiffyStoresApp.configuration.embedded_app?
        render inline: %Q(
          <!DOCTYPE html>
          <html lang="en">
            <head>
              <meta charset="utf-8" />
              <base target="_top">
              <title>Redirecting…</title>
              <script type="text/javascript">
                window.top.location.href = #{url_json};
              </script>
            </head>
            <body>
            </body>
          </html>
        )
      else
        redirect_to_with_fallback url
      end
    end
  end
end
