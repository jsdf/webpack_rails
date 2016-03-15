require_relative './task'

namespace :webpack do
  # build output files once, then exit
  task :build_once => :environment do
    WebpackRails::Task.build_once(Rails.application.config.webpack_rails)
  end

  # run webpack watcher as a rake task, rather than being started by rails
  task :watch do
    puts 'watching for webpack changes'
    WebpackRails::Task.with_app_node_path do
      system "WEBPACK_STDOUT_LOGGING=yes #{WebpackRails::Task.node_command} #{WebpackRails::Task.webpack_task_script}"
    end
  end
end

# run webpack before every 'rake assets:precompile' (eg. build for production)
Rake::Task['assets:precompile'].enhance(['webpack:build_once'])
