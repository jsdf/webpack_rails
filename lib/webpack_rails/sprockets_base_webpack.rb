require 'sprockets'
require_relative './task'

# reopen Sprockets::Base and monkeypatch resolve
class Sprockets::Base
  original_resolve = instance_method(:resolve)

  define_method :resolve, ->(logical_path, options = {}, &block) {
    if logical_path.to_s.include?('.bundle')
      WebpackRails::Task.run_webpack # ensure output files exist so original_resolve doesn't fail
    end
    original_resolve.bind(self).(logical_path, options, &block)
  }
end
