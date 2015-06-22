require 'node_task'
require 'benchmark'
require 'logger'

module WebpackTask
  def self.webpack_gem_dir
    @webpack_gem_dir ||= File.dirname(File.expand_path(__FILE__))
  end

  def self.webpack_task_script
    @webpack_task_script ||= File.join(webpack_gem_dir, './webpack-task.js')
  end

  def self.app_node_path
    @app_node_path ||= File.join((defined?(Rails) ? Rails.root.to_s : Dir.pwd), 'node_modules')
  end

  def self.with_app_node_path
    prev_node_path = ENV['NODE_PATH']
    ENV['NODE_PATH'] = app_node_path
    return_value = yield
    ENV['NODE_PATH'] = prev_node_path
    return_value
  end

  def run_webpack
    result = nil

    task_duration = Benchmark.realtime do
      result = WebpackTask.with_app_node_path do
        task = NodeTask.new(WebpackTask.webpack_task_script)
        task.run
      end
    end
    Rails.logger.info("Webpack: #{(task_duration*1000).round(3)}ms") if defined?(Rails)

    result
  end
end
