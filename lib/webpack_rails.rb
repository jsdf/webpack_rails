require 'sprockets'
require 'sprockets/webpack_environment'
require 'sprockets/webpack_index'

module WebpackRails
  require_relative './webpack_rails/sprockets_integration'
  require_relative './webpack_rails/require_directive_processor'
  require_relative './webpack_rails/task'
  require_relative './webpack_rails/processor'
  require_relative './webpack_rails/engine'
end
