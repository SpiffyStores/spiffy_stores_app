module SpiffyStoresApp
  module WebhookVerification
    extend ActiveSupport::Concern

    included do
      skip_before_action :verify_authenticity_token, raise: false
      before_action :verify_request
    end

    private

    def verify_request
      data = request.raw_post
      return head :unauthorized unless hmac_valid?(data)
    end

    def hmac_valid?(data)
      secret = SpiffyStoresApp.configuration.secret
      digest = OpenSSL::Digest.new('sha256')
      encoded_params = JSON.parse(data).map {|i| "#{URI.escape(i[0].to_s, '&=%')}=#{URI.escape(i[1].to_s, '&%')}"}.sort.join('&')
      ActiveSupport::SecurityUtils.secure_compare(
        spiffy_stores_hmac,
        OpenSSL::HMAC.hexdigest(digest, secret, encoded_params)
      )
    end

    def shop_domain
      request.headers['HTTP_X_SPIFFY_STORES_SHOP_DOMAIN']
    end

    def spiffy_stores_hmac
      request.headers['HTTP_X_SPIFFY_STORES_HMAC_SHA256']
    end
  end
end
