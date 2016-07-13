module SpiffyStoresApp
  module SessionStorage
    extend ActiveSupport::Concern

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
          SpiffyStoresAPI::Session.new(shop.spiffy_stores_domain, shop.spiffy_stores_token)
        end
      end
    end

  end
end
