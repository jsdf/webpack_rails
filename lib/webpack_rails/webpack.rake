require_relative './task'

namespace :webpack do
  task :watch do
    puts 'watching for webpack changes'
    WebpackRails::Task.with_app_node_path do
      system "WEBPACK_STDOUT_LOGGING=yes #{WebpackRails::Task.node_command} #{WebpackRails::Task.webpack_task_script}"
    end
  end

  task :before_assets_precompile do
    # with production config, sprockets index isn't updated correctly by the
    # find_asset monkey patch. instead, we just run it before precompiling assets
    WebpackRails::Task.run_webpack
  end
end

# runs before every 'rake assets:precompile'
Rake::Task['assets:precompile'].enhance(['webpack:before_assets_precompile'])
