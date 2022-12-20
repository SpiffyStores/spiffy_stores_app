# frozen_string_literal: true
module SpiffyStoresApp
  class ScripttagsManagerJob < ActiveJob::Base

    queue_as do
      SpiffyStoresApp.configuration.scripttags_manager_queue_name
    end

    def perform(shop_domain:, shop_token:, scripttags:)
      SpiffyStoresAPI::Session.temp(shop_domain, shop_token) do
        manager = ScripttagsManager.new(scripttags, shop_domain)
        manager.create_scripttags
      end
    end
  end
end
