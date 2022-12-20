# frozen_string_literal: true
require 'rails/generators/base'

module SpiffyStoresApp
  module Generators
    class HomeControllerGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def create_home_controller
        template 'home_controller.rb', 'app/controllers/home_controller.rb'
      end

      def create_home_index_view
        copy_file 'index.html.erb', 'app/views/home/index.html.erb'
        if embedded_app?
          prepend_to_file(
            'app/views/home/index.html.erb',
            File.read(File.expand_path(find_in_source_paths('spiffy_stores_app_ready_script.html.erb')))
          )
        end
      end

      def add_home_index_route
        route "root :to => 'home#index'"
      end

      def embedded_app?
        SpiffyStoresApp.configuration.embedded_app?
      end
    end
  end
end
