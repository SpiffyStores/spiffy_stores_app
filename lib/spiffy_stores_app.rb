require 'spiffy_stores_app/version'

# deps
require 'spiffy_stores_api'
#require 'omniauth-shopify-oauth2'

# config
require 'spiffy_stores_app/configuration'

# engine
require 'spiffy_stores_app/engine'

# jobs
require 'spiffy_stores_app/webhooks_manager_job'
require 'spiffy_stores_app/scripttags_manager_job'

# helpers and concerns
require 'spiffy_stores_app/shop'
require 'spiffy_stores_app/session_storage'
require 'spiffy_stores_app/sessions_concern'
require 'spiffy_stores_app/login_protection'
require 'spiffy_stores_app/webhooks_manager'
require 'spiffy_stores_app/scripttags_manager'
require 'spiffy_stores_app/webhook_verification'
require 'spiffy_stores_app/app_proxy_verification'
require 'spiffy_stores_app/utils'

# session repository
require 'spiffy_stores_app/spiffy_stores_session_repository'
require 'spiffy_stores_app/in_memory_session_store'
