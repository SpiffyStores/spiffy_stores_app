module SpiffyStoresApp
  class WebhooksManagerJob < ActiveJob::Base
    def perform(shop_domain:, shop_token:)
      SpiffyStoresAPI::Session.temp(shop_domain, shop_token) do
        manager = WebhooksManager.new
        manager.create_webhooks
      end
    end
  end
end
