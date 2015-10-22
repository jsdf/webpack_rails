require 'bundler/gem_tasks'

task :spec do
  system './spec.sh'
end

task 'npm_install_gem_deps' do
  system('cd lib/webpack_rails; npm prune && npm install')
end

Rake::Task['build'].enhance(['npm_install_gem_deps'])
