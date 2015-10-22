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

    def evaluate(context, locals)
      return data unless context.pathname.to_s.include?('.bundle')

      # rewrite $asset_paths in strings
      data.gsub(/['"]\$asset_path\/([^'"]+?)['"]/) {|s| "'#{context.asset_path($1)}'" }
    end
  end
end
