require_relative './lib/webpack_rails/version'

Gem::Specification.new do |s|
  s.name        = 'webpack_rails'
  s.version     = WebpackRails::VERSION
  s.licenses    = ['MIT']
  s.summary     = "Integrates Webpack with Rails/Sprockets"
  s.description = "Integrates Webpack with Rails/Sprockets.

The main goal of this gem is to keep things working relatively seamlessly and
automatically alongside existing Sprockets-based code, meeting the
developer-experience expectations of Rails developers, while working towards
the ultimate goal of transitioning off of Sprockets entirely."
  s.authors     = ["James Friend"]
  s.email       = 'james@jsdf.co'
  s.files       = ["lib/webpack_rails.rb"] + Dir["lib/webpack_rails/**/*"] + Dir["lib/sprockets/**/*"]
  s.homepage    = 'https://rubygems.org/gems/webpack_rails'
  s.add_runtime_dependency 'node_task', '0.3.5'
  s.add_runtime_dependency 'sprockets', '~> 3'
end
