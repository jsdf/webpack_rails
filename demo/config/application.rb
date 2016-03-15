require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Demo
  class Application < Rails::Application
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.assets.precompile += %w( posts.bundle.js )

    # where webpack bundles will be output
    config.assets.paths << Rails.root.join('tmp', 'webpack', 'bundles')

    config.webpack_rails.dev_server = Rails.env.development?
    config.webpack_rails.webpack_config_file = Rails.root.join('config', 'webpack.config.js')
    config.webpack_rails.port = 9080
  end
end
