require 'tilt'

require_relative './sprockets_index_webpack'
require_relative './task'

module WebpackRails
  class Processor < Tilt::Template
    def prepare
    end

    def evaluate(context, locals)
      return data unless context.pathname.to_s.include?('.bundle')

      # wait til webpack is done before loading
      WebpackRails::Task.run_webpack

      bundle_contents = context.pathname.open.read
      # rewrite $asset_paths in strings
      bundle_contents.gsub(/['"]\$asset_path\/([^'"]+?)['"]/) {|s| "'#{context.asset_path($1)}'" }
    end
  end
end
