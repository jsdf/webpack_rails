require_relative './task'

namespace :webpack do
  task :watch do
    puts 'watching for webpack changes'
    WebpackRails::Task.with_app_node_path do
      system "WEBPACK_STDOUT_LOGGING=yes #{WebpackRails::Task.node_command} #{WebpackRails::Task.webpack_task_script}"
    end
  end  
end

