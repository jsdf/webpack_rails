require_relative './sprockets_environment'

module WebpackRails
  class Engine < ::Rails::Engine
    engine_name 'webpack'

    config.webpack_rails = ActiveSupport::OrderedOptions.new

    initializer :setup_webpack_rails, after: 'sprockets.environment', group: :all do |app|
      app.config.assets.configure do |env|
        WebpackRails::SprocketsEnvironment.enhance!(env, app.config.webpack_rails)

        # where [name].bundle.js files should be
        env.append_path Rails.root.join('tmp/webpack/bundles')
      end
    end

    rake_tasks do
      load 'webpack_rails/webpack.rake'
    end
  end
end
