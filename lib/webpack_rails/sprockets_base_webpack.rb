require 'sprockets'

# reopen Sprockets::Base
class Sprockets::Base
  def self.before_find_asset(&block)
    @before_find_asset_callbacks ||= []
    @before_find_asset_callbacks << block
  end

  def self.run_before_find_asset_callbacks
    @before_find_asset_callbacks ||= []
    @before_find_asset_callbacks.each do |block|
      block.call
    end
  end
end
