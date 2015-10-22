require 'sprockets/webpack_environment'

module WebpackRails
  class Engine < ::Rails::Engine
    engine_name 'webpack'

    initializer :setup_webpack_rails, after: 'sprockets.environment', group: :all do |app|
      app.assets = Sprockets::WebpackEnvironment.copy_from(app.assets)
      unless app.config.webpack_rails
        fail 'app.config.webpack_rails not set'
      end
      app.assets.webpack_config = app.config.webpack_rails

      WebpackRails::SprocketsIntegration.install(app.assets, app.assets.webpack_config)

      # where [name].bundle.js files should be
      app.assets.append_path Rails.root.join('tmp/webpack/bundles')

      # stop sprockets from ruining inline sourcemaps in dev
      if Rails.env.development?
        app.assets.unregister_postprocessor 'application/javascript', ::Sprockets::SafetyColons
      end
    end

    rake_tasks do
      load 'webpack_rails/webpack.rake'
    end
  end
end
