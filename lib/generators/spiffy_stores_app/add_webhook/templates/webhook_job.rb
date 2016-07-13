class <%= @job_class_name %> < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Store.find_by(spiffystores_domain: shop_domain)

    shop.with_spiffy_stores_session do
    end
  end
end
