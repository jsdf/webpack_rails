require 'sprockets'
require 'webpack_rails/sprockets_cached_environment'
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
    end
  end
end
