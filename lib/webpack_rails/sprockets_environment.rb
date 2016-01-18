require 'sprockets'
require 'webpack_rails/sprockets_cached_environment'
require 'webpack_rails/require_directive_processor'
require 'webpack_rails/processor'
require 'webpack_rails/config'

module WebpackRails
  class SprocketsEnvironment
    module EnvironmentWebpackInstanceMethods
      def webpack_task_config=(new_webpack_task_config)
        @webpack_task_config = new_webpack_task_config
      end

      def webpack_task_config
        WebpackRails::Config::DEFAULT_CONFIG.clone.merge(@webpack_task_config)
      end

      def install_webpack_task_processors!
        file_processor = WebpackRails::Processor.configure(webpack_task_config)
        require_directive_processor = WebpackRails::RequireDirectiveProcessor.configure(webpack_task_config)

        register_preprocessor 'application/javascript', file_processor
        register_preprocessor 'text/css', file_processor
        register_preprocessor 'application/javascript', require_directive_processor
        register_preprocessor 'text/css', require_directive_processor
      end

      def cached
        WebpackRails::SprocketsCachedEnvironment.new(self)
      end

      # sprockets 2.x compat
      def index
        cached
      end
    end

    def self.enhance!(env, webpack_task_config)
      env.extend(EnvironmentWebpackInstanceMethods)
      env.webpack_task_config = webpack_task_config
      env.install_webpack_task_processors!
    end
  end
end
