$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require "spiffy_stores_app/version"

Gem::Specification.new do |s|
  s.name        = "spiffy_stores_app"
  s.version     = SpiffyStoresApp::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Spiffy Stores"
  s.summary     = %q{This gem is used to get quickly started with the Spiffy Stores API}

  s.required_ruby_version = ">= 2.2.4"

  s.add_runtime_dependency('rails', '>= 4.2.6')
  s.add_runtime_dependency('spiffy_stores_api', '~> 4.2.2')
# s.add_runtime_dependency('omniauth-shopify-oauth2', '~> 1.1.11')

  s.add_development_dependency('rake')
  s.add_development_dependency('byebug')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('minitest')
  s.add_development_dependency('mocha')

  s.files         = `git ls-files`.split("\n").reject { |f| f.match(%r{^(test|example)/}) }
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.require_paths = ["lib"]
end
