# frozen_string_literal: true
require 'spiffy_stores_app/version'

# deps
require 'spiffy_stores_api'
require 'omniauth-spiffy-oauth2'

# config
require 'spiffy_stores_app/configuration'

# engine
require 'spiffy_stores_app/engine'

# utils
require 'spiffy_stores_app/utils'

# controller concerns
require 'spiffy_stores_app/controller_concerns/localization'
require 'spiffy_stores_app/controller_concerns/login_protection'
require 'spiffy_stores_app/controller_concerns/embedded_app'
require 'spiffy_stores_app/controller_concerns/webhook_verification'
require 'spiffy_stores_app/controller_concerns/app_proxy_verification'

# jobs
require 'spiffy_stores_app/jobs/webhooks_manager_job'
require 'spiffy_stores_app/jobs/scripttags_manager_job'

# mangers
require 'spiffy_stores_app/managers/webhooks_manager'
require 'spiffy_stores_app/managers/scripttags_manager'

# session
require 'spiffy_stores_app/session/session_storage'
require 'spiffy_stores_app/session/session_repository'
require 'spiffy_stores_app/session/in_memory_session_store'
