require 'sprockets'
require_relative './task'

# reopen Sprockets::Index and monkeypatch find_asset
class Sprockets::Index
  original_find_asset = instance_method(:find_asset)

  define_method :find_asset, ->(path, options = {}) {
    unless @_webpack_built
      WebpackRails::Task.run_webpack # ensure output files exist so original_find_asset doesn't fail
      @_webpack_built = true
    end
    original_find_asset.bind(self).(path, options)
  }
end
