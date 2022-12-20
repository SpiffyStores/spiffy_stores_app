# frozen_string_literal: true
module SpiffyStores
  class AfterAuthenticateJob < ActiveJob::Base
    def perform(shop_domain:)
      shop = Shop.find_by(short_name: shop_domain)

      shop.with_spiffy_stores_session do
      end
    end
  end
end
