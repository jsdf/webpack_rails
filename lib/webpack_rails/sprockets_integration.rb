require 'sprockets'
require 'sprockets/webpack_environment'
require 'sprockets/webpack_index'

require_relative './require_directive_processor'
require_relative './processor'

module WebpackRails
  class SprocketsIntegration
    def self.install(environment, webpack_config)
      file_processor = WebpackRails::Processor.configure(webpack_config)
      require_directive_processor = WebpackRails::RequireDirectiveProcessor.configure(webpack_config)

      environment.register_preprocessor 'application/javascript', file_processor
      environment.register_preprocessor 'text/css', file_processor
      environment.register_preprocessor 'application/javascript', require_directive_processor
      environment.register_preprocessor 'text/css', require_directive_processor
    end
  end
end
