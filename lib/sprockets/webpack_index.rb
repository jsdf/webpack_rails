require 'sprockets'
require 'sprockets/index'

module Sprockets
  class WebpackIndex < Index
    def find_asset(*args)
      if @environment.webpack_task_config[:dev_server] || @environment.webpack_task_config[:watch]
        # ensure webpack-dev-server is running or watcher has finished building
        WebpackRails::Task.run_webpack(@environment.webpack_task_config)
      end

      super
    end
  end
end
