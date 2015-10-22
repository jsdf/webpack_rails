require 'sprockets'
require_relative './require_directive_processor'
require_relative './processor'

module WebpackRails
  class Sprockets
    def self.install(environment = ::Sprockets, configuration)
      require_directive_processor = WebpackRails::RequireDirectiveProcessor.configure(environment, configuration)

      environment.register_preprocessor('application/javascript', WebpackRails::Processor)
      environment.register_preprocessor('text/css', WebpackRails::Processor)
      environment.register_preprocessor 'application/javascript', require_directive_processor
      environment.register_preprocessor 'text/css', require_directive_processor
    end
  end
end
