Gem::Specification.new do |s|
  s.name        = 'webpack_rails'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = "This is an webpack_rails!"
  s.description = "Much longer explanation of the webpack_rails!"
  s.authors     = ["James Friend"]
  s.email       = 'james@jsdf.co'
  s.files       = ["lib/webpack_rails.rb"] + Dir["lib/webpack_rails/**/*"]
  s.homepage    = 'https://rubygems.org/gems/webpack_rails'
  s.add_runtime_dependency 'node_task',  '~> 0.1.0', '>= 0.1.1'
end
