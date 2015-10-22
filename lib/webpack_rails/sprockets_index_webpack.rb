require 'sprockets'
require_relative './task'

# reopen Sprockets::Index and monkeypatch find_asset
class Sprockets::Index
  original_find_asset = instance_method(:find_asset)

  define_method :find_asset, ->(path, options = {}) {
    self.class.run_before_find_asset_callbacks
    original_find_asset.bind(self).(path, options)
  }
end
