module SpiffyStoresApp
  module Generators
    class SpiffyStoresAppGenerator < Rails::Generators::Base
      def initialize(args, *options)
        @opts = options.first
        super(args, *options)
      end

      def run_all_generators
        generate "spiffy_stores_app:install #{@opts.join(' ')}"
        generate "spiffy_stores_app:shop_model"
        generate "spiffy_stores_app:home_controller"
      end
    end
  end
end
