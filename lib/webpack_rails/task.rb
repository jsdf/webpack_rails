require 'node_task'
require 'benchmark'
require 'fileutils'

module WebpackRails
  class Task < NodeTask
    # wraps NodeTask::Error
    class Error < StandardError
      def initialize(node_task_error)
        super(node_task_error.to_s)

        js_error = node_task_error.js_error

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

      def webpack_task_watch_script
        @webpack_task_watch_script ||= File.join(webpack_gem_dir, 'webpack-task-watch.js')
      end

      def webpack_task_dev_server_script
        @webpack_task_dev_server_script ||= File.join(webpack_gem_dir, 'webpack-task-dev-server.js')
      end

      def webpack_task_script(opts)
        return webpack_task_watch_script if opts[:watch]
        return webpack_task_dev_server_script if opts[:dev_server]
        fail "can't determine which task to run"
      end

      def webpack_task_opts(opts)
        opts.merge(
          webpack_config_file: opts[:webpack_config_file] ? opts[:webpack_config_file].to_s : nil,
        )
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

      def build_once(webpack_task_config)
        WebpackRails::Task.with_app_node_path do
          webpack_cmd_script = `#{WebpackRails::Task.node_command} -e "process.stdout.write(require.resolve('webpack/bin/webpack.js'))"`
          system "#{WebpackRails::Task.node_command} '#{webpack_cmd_script}' --config #{webpack_task_config[:webpack_config_file]}"
        end
      end

      def run_webpack(opts = {})
        return if ENV['DISABLE_WEBPACK']

        result = nil
        task_duration = Benchmark.realtime do
          with_app_node_path do
            begin
              task = self.new(webpack_task_script(opts))
              result = task.run(webpack_task_opts(opts))
            rescue NodeTask::Error => e
              raise self::Error.new(e)
            end
          end
        end

        task_duration_ms = task_duration * 1000
        if defined?(Rails) && result
          if opts[:dev_server] && result[:started]
            Rails.logger.info("Started webpack-dev-server in #{task_duration_ms.round(0)}ms")
          end
        end
        result
      end

      private

      def _make_working_dir
        # one node_task daemon will be created per unique working dir
        wd = File.join(root_dir, 'tmp', 'webpack', 'task')
        FileUtils.mkpath(wd)
        wd
      end
    end
  end
end
