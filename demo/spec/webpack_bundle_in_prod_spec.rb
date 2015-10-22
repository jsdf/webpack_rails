require 'rails_helper'

RSpec.describe "webpack bundle in prod" do
  before(:each) do
    root = File.expand_path('../../', __FILE__)

    @env = Sprockets::Environment.new
    @env.append_path File.join(root, 'app/assets/javascripts')
    @env.append_path File.join(root, 'tmp/webpack/bundles')

    WebpackRails::Sprockets.install(@env, {
      use_dev_server: false,
    })

    # run webpack as in assets:precompile
    system "bundle exec rake webpack:build_once"
  end

  it "builds successfully" do
    asset = @env["application.js"]
    expect(asset).not_to be_nil
    expect(asset.to_s).to include('PostsScreen')
  end
end

