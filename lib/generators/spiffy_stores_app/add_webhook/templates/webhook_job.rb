# frozen_string_literal: true
class <%= @job_class_name %> < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(spiffy_stores_domain: shop_domain)

    shop.with_spiffy_stores_session do
    end
  end
end
