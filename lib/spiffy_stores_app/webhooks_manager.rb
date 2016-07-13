module SpiffyStoresApp
  class WebhooksManager
    class CreationFailed < StandardError; end

    def self.queue(shop_domain, shop_token)
      SpiffyStoresApp::WebhooksManagerJob.perform_later(shop_domain: shop_domain, shop_token: shop_token)
    end

    def recreate_webhooks!
      destroy_webhooks
      create_webhooks
    end

    def create_webhooks
      return unless required_webhooks.present?

      required_webhooks.each do |webhook|
        create_webhook(webhook) unless webhook_exists?(webhook[:topic])
      end
    end

    def destroy_webhooks
      SpiffyStoresAPI::Webhook.all.each do |webhook|
        SpiffyStoresAPI::Webhook.delete(webhook.id) if is_required_webhook?(webhook)
      end

      @current_webhooks = nil
    end

    private

    def required_webhooks
      SpiffyStoresApp.configuration.webhooks
    end

    def is_required_webhook?(webhook)
      required_webhooks.map{ |w| w[:address] }.include? webhook.address
    end

    def create_webhook(attributes)
      attributes.reverse_merge!(format: 'json')
      webhook = SpiffyStoresAPI::Webhook.create(attributes)
      raise CreationFailed unless webhook.persisted?
      webhook
    end

    def webhook_exists?(topic)
      current_webhooks[topic]
    end

    def current_webhooks
      @current_webhooks ||= SpiffyStoresAPI::Webhook.all.index_by(&:topic)
    end
  end
end
