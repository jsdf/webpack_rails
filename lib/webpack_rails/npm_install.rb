task 'npm_install_gem_deps' do
  system("cd \"#{File.dirname(__FILE__)}\"; npm prune && npm install")
end
