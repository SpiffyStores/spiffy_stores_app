# frozen_string_literal: true
module SpiffyStoresApp
  module SessionStorage
    extend ActiveSupport::Concern

    included do
      validates :spiffy_stores_domain, presence: true, uniqueness: true
      validates :spiffy_stores_token, presence: true
    end

    def with_spiffy_stores_session(&block)
      SpiffyStoresAPI::Session.temp(spiffy_stores_domain, spiffy_stores_token, &block)
    end

    class_methods do
      def store(session)
        shop = self.find_or_initialize_by(spiffy_stores_domain: session.url)
        shop.spiffy_stores_token = session.token
        shop.save!
        shop.id
      end

      def retrieve(id)
        return unless id

        if shop = self.find_by(id: id)
          SpiffyStoresAPI::Session.new(shop.spiffy_stores_domain, shop.spiffy_stores_token, shop)
        end
      end
    end

  end
end
