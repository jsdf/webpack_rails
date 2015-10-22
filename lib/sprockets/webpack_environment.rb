require 'sprockets'
require 'sprockets/environment'
require 'sprockets/webpack_index'

module Sprockets
  class WebpackEnvironment < Environment
    DEFAULT_CONFIG = {
      protocol: 'http',
      host: 'localhost',
      port: 9876,
    }

    module WebpackEnvironmentMethods

      def webpack_config=(new_webpack_config)
        @webpack_config = new_webpack_config
      end

      def webpack_config
        WebpackEnvironment::DEFAULT_CONFIG.merge(@webpack_config)
      end

      def index
        Sprockets::WebpackIndex.new(self)
      end
    end

    def self.copy_from(other_env)
      # new_env = WebpackEnvironment.new(nil, false) # don't init
      # copy instance vars from previous env
      # other_env.instance_variables.each do |name|
      #   new_env.instance_variable_set(name, instance_variable_get(name))
      # end
      # new_env
      other_env.extend(WebpackEnvironmentMethods)
      other_env
    end

    # def initialize(root, init_via_super = true)
    #   super(root) if init_via_super
    # end

    # def index
    #   WebpackIndex.new(self)
    # end
  end
end
