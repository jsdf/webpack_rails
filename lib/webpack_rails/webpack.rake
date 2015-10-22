require_relative './task'

namespace :webpack do
  task :watch do
    puts 'watching for webpack changes'
    WebpackRails::Task.with_app_node_path do
      system "WEBPACK_STDOUT_LOGGING=yes #{WebpackRails::Task.node_command} #{WebpackRails::Task.webpack_task_script}"
    end
  end

  task :build_once => :environment do
    WebpackRails::Task.build_once(Rails.application.config.webpack_rails)
  end
end

# runs before every 'rake assets:precompile'
# with production config, sprockets index isn't updated correctly by the
# find_asset monkey patch. instead, we just run it before precompiling assets
Rake::Task['assets:precompile'].enhance(['webpack:build_once'])
