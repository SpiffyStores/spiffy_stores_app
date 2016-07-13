module SpiffyStoresApp
  module Shop
    extend ActiveSupport::Concern

    included do
      validates :spiffy_stores_domain, presence: true, uniqueness: true
      validates :spiffy_stores_token, presence: true
    end

    def with_spiffy_stores_session(&block)
      SpiffyStoresAPI::Session.temp(spiffy_stores_domain, spiffy_stores_token, &block)
    end

  end
end
