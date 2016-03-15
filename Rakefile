require 'bundler/gem_tasks'
require_relative './lib/webpack_rails/npm_install'

task :spec do
  system './spec.sh'
end

Rake::Task['spec'].enhance(['npm_install_gem_deps'])
Rake::Task['build'].enhance(['npm_install_gem_deps'])

task :default => [:spec]
