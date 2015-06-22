require 'tilt' # TODO: add to gemspec

require_relative './sprockets_base_webpack'
require_relative './webpack_task'

class WebpackProcessor < Tilt::Template
  include WebpackTask

  def prepare
  end

  def evaluate(context, locals)
    return data unless context.pathname.to_s.include?('.bundle')

    # wait til webpack is done before loading
    result = run_webpack

    result[:modules].map{|m| context.depend_on m}

    # TODO: rewrite $asset_root in paths
    context.pathname.open.read
  end
end
