require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'sprockets'
require 'pathname'
require 'node_task'
require 'benchmark'
require 'awesome_print'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WebpackTask
  def run_webpack
    result = nil
    time = Benchmark.realtime do
      t = NodeTask.new './webpack/webpack-task'
      result = t.run
    end
    puts "ran webpack task in #{time*1000} milliseconds"
    result
  end
end

# reopen Sprockets::Base and monkeypatch find_asset
class Sprockets::Base
  include WebpackTask

  original_find_asset = instance_method(:find_asset)

  define_method :find_asset, ->(path, *rest) {
    puts "find_asset #{path}"
    if path.to_s.include?('.bundle')
      puts 'find_asset running webpack'
      run_webpack # ensure output files exist so original_find_asset doesn't fail
    end

    original_find_asset.bind(self).(path, *rest)
  }
end

# reopen Sprockets::Context and monkeypatch resolve
class Sprockets::Context
  include WebpackTask

  original_resolve = instance_method(:resolve)

  define_method :resolve, ->(path, *rest) {
    puts "resolve #{path}"
    if path.to_s.include?('.bundle')
      puts 'resolve running webpack'
      result = run_webpack # ensure output files exist so original_resolve doesn't fail
      # result[:modules].each{|m| depend_on m} if result[:modules]
    end
    original_resolve.bind(self).(path, *rest)
  }
end

class WebpackMiddleware
  include WebpackTask

  def initialize(app)
   @app = app
  end

  def call(env)
    puts "WebpackMiddleware"
    puts 'env["PATH_INFO"]='+env["PATH_INFO"]
    run_webpack if env["PATH_INFO"] && env["PATH_INFO"].include?('.bundle')
    @app.call(env)
  end
end

module Demo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # config.middleware.insert_before ActionDispatch::Static, WebpackMiddleware

    assets.append_path 'tmp/webpack' # where [name].bundle.js files will end up
    
    components = Dir['app/assets/components/*/'].map{|p| File.basename p}
    components.each{|c| config.assets.precompile << "#{c}.bundle.*" }

    class WebpackProcessor < Sprockets::Processor
      include WebpackTask

      def evaluate(context, locals)
        return super unless context.pathname.to_s.include?('.bundle')

        # bundle_name = context.pathname.basename(".bundle#{File.extname(path)}").to_s

        # wait til webpack is done before loading
        result = run_webpack
        # result[:modules].each{|m| context.depend_on m} if result[:modules]

        context.pathname.open.read
      end
    end

    assets.register_preprocessor('application/javascript', WebpackProcessor)
  end
end
