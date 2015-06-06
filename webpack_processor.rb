require 'tilt'

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
    context.pathname.open.read
  end
end
