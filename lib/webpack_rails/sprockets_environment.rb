require 'sprockets'
require 'sprockets/webpack_index'
require 'webpack_rails/require_directive_processor'
require 'webpack_rails/processor'

module WebpackRails
  class SprocketsEnvironment
    DEFAULT_WEBPACK_TASK_CONFIG = {
      dev_server: false,
      protocol: 'http',
      host: 'localhost',
      port: 9876,
    }

    module EnvironmentWebpackInstanceMethods
      def webpack_task_config=(new_webpack_task_config)
        @webpack_task_config = new_webpack_task_config
      end

      def webpack_task_config
        @webpack_task_config.merge(DEFAULT_WEBPACK_TASK_CONFIG).merge(@webpack_task_config)
      end

      def install_webpack_task_processors!
        file_processor = WebpackRails::Processor.configure(webpack_task_config)
        require_directive_processor = WebpackRails::RequireDirectiveProcessor.configure(webpack_task_config)

        register_preprocessor 'application/javascript', file_processor
        register_preprocessor 'text/css', file_processor
        register_preprocessor 'application/javascript', require_directive_processor
        register_preprocessor 'text/css', require_directive_processor
      end

      def index
        Sprockets::WebpackIndex.new(self)
      end
    end

    def self.enhance!(env, webpack_task_config)
      env.extend(EnvironmentWebpackInstanceMethods)
      env.webpack_task_config = webpack_task_config
      env.install_webpack_task_processors!
    end
  end
end
