require 'tilt'

module WebpackRails
  class Processor < Tilt::Template
    def self.configure(webpack_task_config)
      Class.new(Processor) do
        self.config = webpack_task_config
      end
    end

    def self.config=(new_config)
      @config = new_config
    end

    def self.config
      @config
    end

    def prepare
    end

    def rewrite_asset_paths(contents, context)
      contents.gsub(/['"]\$asset_path\/([^'"]+?)['"]/) {|s| "'#{context.asset_path($1)}'" }
    end

    def dependable_asset(filepath)
      File.file?(filepath) # ignore non-filepath entries
    end

    def evaluate(context, locals)
      return data unless context.pathname.to_s.include?('.bundle')

      file_contents = nil
      if self.class.config[:watch]
        result = WebpackRails::Task.run_webpack(self.class.config)

        # add webpack bundle dependencies as sprockets dependencies for this file
        result[:modules].map do |m|
          context.depend_on(m) if dependable_asset(m)
        end

        file_contents = context.pathname.open.read # reload file contents after build
      else
        file_contents = data
      end

      rewrite_asset_paths(file_contents, context)
    end
  end
end
