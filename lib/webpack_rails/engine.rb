require_relative './processor'

module WebpackRails
  class Engine < ::Rails::Engine
    initializer :setup_webpack_rails, :after => "sprockets.environment", :group => :all do |app|
      # where [name].bundle.js files should be
      app.assets.append_path Rails.root.join('tmp/webpack/bundles')
      # process 
      app.assets.register_preprocessor('application/javascript', WebpackRails::Processor)
    end
  end
end
