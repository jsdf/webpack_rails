require 'json'
require_relative './version'
require 'sprockets/directive_processor'

module WebpackRails
  class RequireDirectiveProcessor
    DIRECTIVE_PATTERN = /^.*?=\s*webpack_require\s+(.*?)\s*$/

    def self.configure(webpack_task_config)
      Class.new(RequireDirectiveProcessor) do
        self.config = webpack_task_config
      end
    end

    def self.config=(new_config)
      @cache_key = nil
      @instance = nil
      @config = new_config
    end

    def self.config
      @config
    end

    def self.cache_key
      config_serialized = @config ? @config.to_json : '{}'
      @cache_key ||= "RequireDirectiveProcessor:#{::WebpackRails::VERSION}:#{config_serialized}".freeze
    end

    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def config
      self.class.config
    end

    def dev_server_base_url
      "#{config[:protocol]}://#{config[:host]}:#{config[:port]}"
    end

    def process_require(context, bundle_filename)
      if config[:dev_server]
        if bundle_filename.end_with? '.js'
          # emit a script tag pointing at the dev server js url
          return %{document.write('<script src="#{dev_server_base_url}/#{bundle_filename}"></script>');}
        end
        # probably a css file, contents will be included in js instead to enable hot module replacement
        return "\n"
      end

      # will be handled by normal sprockets require
      context.require_asset(bundle_filename)
      return "\n"
    end

    def call(input)
      data     = input[:data]
      context  = input[:environment].context_class.new(input)

      output = data.gsub(DIRECTIVE_PATTERN) do |match_text|
        process_require(context, $1)
      end

      context.metadata.merge(data: output)
    end
  end
end
