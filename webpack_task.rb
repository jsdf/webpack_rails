require 'node_task'
require 'benchmark'
require 'logger'

module WebpackTask
  def run_webpack
    result = nil
    time = Benchmark.realtime do
      # TODO: move the task js inside the gem
      t = NodeTask.new './webpack-task'
      result = t.run
    end
    Rails.logger.info("Webpack: #{(time*1000).round(3)}ms") if defined?(Rails)
    result
  end
end
