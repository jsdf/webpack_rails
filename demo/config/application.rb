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

    config.webpack_rails = {
      use_dev_server: Rails.env.development?,
      dev_server_host: 'http://localhost:9876',
    }
  end
end
