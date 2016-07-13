module SpiffyStoresApp
  module Utils

    def self.sanitize_shop_domain(shop_domain)
      name = shop_domain.to_s.strip
      name += ".#{SpiffyStoresApp.configuration.spiffy_stores_domain}" if !name.include?("#{SpiffyStoresApp.configuration.spiffy_stores_domain}") && !name.include?(".")
      name.sub!(%r|https?://|, '')

      u = URI("http://#{name}")
      u.host && u.host.ends_with?(".#{SpiffyStoresApp.configuration.spiffy_stores_domain}") ? u.host : nil
    rescue URI::InvalidURIError
      nil
    end

  end
end
