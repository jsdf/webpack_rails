require 'node_task'
require 'benchmark'
require 'fileutils'

module WebpackRails
  class Task < NodeTask
    # wraps NodeTask::Error
    class Error < StandardError
      def initialize(node_task_error)
        super(node_task_error.to_s)

        # TODO: expose @js_error from NodeTask::Error
        js_error = node_task_error.instance_variable_get(:@js_error)
        set_backtrace(js_error[:stack].split('\n')) if js_error
      end
    end

    class << self
      def root_dir
        @root_dir ||= defined?(Rails) ? Rails.root.to_s : Dir.pwd
      end

      def working_dir
        @working_dir ||= _make_working_dir
      end

      def webpack_gem_dir
        @webpack_gem_dir ||= File.dirname(File.expand_path(__FILE__))
      end

      def webpack_task_script
        @webpack_task_script ||= File.join(webpack_gem_dir, 'webpack-task.js')
      end

      def app_node_path
        @app_node_path ||= File.join(root_dir, 'node_modules')
      end

      def with_app_node_path
        prev_node_path = ENV['NODE_PATH']
        ENV['NODE_PATH'] = app_node_path
        return_value = nil
        Dir.chdir(root_dir) do
          return_value = yield
        end
        ENV['NODE_PATH'] = prev_node_path
        return_value
      end

      def run_webpack(opts = nil)
        return if ENV['DISABLE_WEBPACK']

        task_duration = Benchmark.realtime do
          with_app_node_path do
            begin
              task = self.new
              task.run(opts)
            rescue NodeTask::Error => e
              raise self::Error.new(e)
            end
          end
        end

        task_duration_ms = task_duration * 1000
        if defined?(Rails) && task_duration_ms > 10
          Rails.logger.info("Webpack: #{task_duration_ms.round(0)}ms")
        end
      end

      private

      def _make_working_dir
        # one node_task daemon will be created per unique working dir
        wd = File.join(root_dir, 'tmp', 'webpack', 'task')
        FileUtils.mkpath(wd)
        wd
      end
    end

    def initialize
      super(self.class.webpack_task_script)
    end
  end
end
