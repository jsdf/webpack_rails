require File.expand_path('../boot', __FILE__)

require 'rails/all'
require_relative '../../webpack_processor'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Demo
  class Application < Rails::Application
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    assets.append_path 'tmp/webpack' # where [name].bundle.js files will end up
    config.assets.precompile += %w( posts.bundle.js )

    assets.register_preprocessor('application/javascript', WebpackProcessor)
  end
end
