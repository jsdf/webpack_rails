require 'json'

module WebpackRails
  VERSION = JSON.load(File.new(File.expand_path('../package.json', __FILE__)))['version']
end
