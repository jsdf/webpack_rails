require_relative './sprockets'

module WebpackRails
  class Engine < ::Rails::Engine
    engine_name 'webpack'

    initializer :setup_webpack_rails, after: 'sprockets.environment', group: :all do |app|
      # where [name].bundle.js files should be
      app.assets.append_path Rails.root.join('tmp/webpack/bundles')

      WebpackRails::Sprockets.install(app.assets, app.config.webpack_rails)

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
