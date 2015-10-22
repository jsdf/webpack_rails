require 'rails_helper'
require 'sprockets/webpack_environment'
require 'webpack_rails/sprockets_integration'

RSpec.describe "webpack bundle in dev" do
  before(:each) do
    root = File.expand_path('../../', __FILE__)

    @env = Sprockets::Environment.new
    @env = Sprockets::WebpackEnvironment.copy_from(@env)
    @env.append_path File.join(root, 'app/assets/javascripts')
    @env.append_path File.join(root, 'tmp/webpack/bundles')

    @env.webpack_config = {
      dev_server: true,
      host: 'localhost',
      port: 9876,
    }

    WebpackRails::SprocketsIntegration.install(@env, @env.webpack_config)
  end

  it "builds successfully" do
    asset = @env["application.js"]
    expect(asset).not_to be_nil
    expect(asset.to_s).to include(%{document.write('<script src="http://localhost:9876/posts.bundle.js"></script>');})
  end
end

