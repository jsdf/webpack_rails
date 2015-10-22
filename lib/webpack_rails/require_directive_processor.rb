require 'tilt'

module WebpackRails
  class RequireDirectiveProcessor < Tilt::Template
    DIRECTIVE_PATTERN = /^.*?=\s*webpack_require\s+(.*?)\s*$/

    def self.configure(environment = ::Sprockets, configuration)
      Class.new(RequireDirectiveProcessor) do
        self.config = configuration
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

    def config
      self.class.config
    end

    def process_require(context, locals, bundle_filename)
      # allow webpack-dev-server to handle
      if config[:use_dev_server]
        # TODO: extract webpack dev server host
        if bundle_filename.end_with? '.js'
          return %{document.write('<script src="#{config[:dev_server_host]}/#{bundle_filename}"></script>');}
        end
      end
      # will be handled by normal sprockets require
      context.require_asset(bundle_filename)
      return ''
    end

    def evaluate(context, locals)
      data.gsub(DIRECTIVE_PATTERN) do |match_text|
        process_require(context, locals, $1)
      end
    end
  end
end
