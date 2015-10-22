require_relative './task'

namespace :webpack do
  task :watch do
    puts 'watching for webpack changes'
    WebpackRails::Task.with_app_node_path do
      system "WEBPACK_STDOUT_LOGGING=yes #{WebpackRails::Task.node_command} #{WebpackRails::Task.webpack_task_script}"
    end
  end

  task :build_once do
    WebpackRails::Task.with_app_node_path do
      webpack_cmd_script = `#{WebpackRails::Task.node_command} -e "process.stdout.write(require.resolve('webpack/bin/webpack.js'))"`
      system "#{WebpackRails::Task.node_command} #{webpack_cmd_script} --config './config/webpack.config.js'"
    end
  end
end

# runs before every 'rake assets:precompile'
# with production config, sprockets index isn't updated correctly by the
# find_asset monkey patch. instead, we just run it before precompiling assets
Rake::Task['assets:precompile'].enhance(['webpack:build_once'])
