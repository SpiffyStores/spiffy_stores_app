# frozen_string_literal: true
module SpiffyStoresApp
  class Configuration

    # SpiffyStores App settings. These values should match the configuration
    # for the app in your SpiffyStores Partners page. Change your settings in
    # `config/initializers/spiffy_stores_app.rb`
    attr_accessor :application_name
    attr_accessor :api_key
    attr_accessor :secret
    attr_accessor :scope
    attr_accessor :embedded_app
    alias_method  :embedded_app?, :embedded_app
    attr_accessor :webhooks
    attr_accessor :scripttags
    attr_accessor :after_authenticate_job
    attr_accessor :session_repository

    # customise urls
    attr_accessor :root_url

    # customise ActiveJob queue names
    attr_accessor :scripttags_manager_queue_name
    attr_accessor :webhooks_manager_queue_name

    # configure spiffystores domain for local spiffy_stores development
    attr_accessor :spiffy_stores_domain

    # allow namespacing webhook jobs
    attr_accessor :webhook_jobs_namespace

    def initialize
      @root_url = '/'
      @spiffy_stores_domain = 'spiffystores.com'
      @scripttags_manager_queue_name = Rails.application.config.active_job.queue_name
      @webhooks_manager_queue_name = Rails.application.config.active_job.queue_name
    end

    def login_url
      File.join(@root_url, 'login')
    end

    def session_repository=(klass)
      if Rails.configuration.cache_classes
        SpiffyStoresApp::SessionRepository.storage = klass
      else
        ActiveSupport::Reloader.to_prepare do
          SpiffyStoresApp::SessionRepository.storage = klass
        end
      end
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
