require_relative './sprockets_environment'
require_relative './helper'
require_relative './config'

module WebpackRails
  class Engine < ::Rails::Engine
    engine_name 'webpack'

    config.webpack_rails = ActiveSupport::OrderedOptions.new
    WebpackRails::Config::DEFAULT_CONFIG.each do |k, v|
      config.webpack_rails.[]= k, v
    end

    initializer :setup_webpack_rails, after: 'sprockets.environment', group: :all do |app|
      app.config.assets.configure do |env|
        # ensure webpack has run before sprockets resolves assets
        WebpackRails::SprocketsEnvironment.enhance!(env, app.config.webpack_rails)
      end
    end

    config.after_initialize do
      ActiveSupport.on_load(:action_view) do
        include WebpackRails::Helper
      end
    end

    rake_tasks do
      load 'webpack_rails/webpack.rake'
    end
  end
end
