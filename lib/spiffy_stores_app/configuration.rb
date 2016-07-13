module SpiffyStoresApp
  class Configuration

    # SpiffyStores App settings. These values should match the configuration
    # for the app in your SpiffyStores Partners page. Change your settings in
    # `config/initializers/spiffy_stores_app.rb`
    attr_accessor :api_key
    attr_accessor :secret
    attr_accessor :scope
    attr_accessor :embedded_app
    alias_method  :embedded_app?, :embedded_app
    attr_accessor :webhooks
    attr_accessor :scripttags

    # configure spiffy_stores domain for local spiffy_stores development
    attr_accessor :spiffy_stores_domain

    def initialize
      @spiffy_stores_domain = 'my.spiffystores.com'
    end

    def has_webhooks?
      webhooks.present?
    end

    def has_scripttags?
      scripttags.present?
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end
end
