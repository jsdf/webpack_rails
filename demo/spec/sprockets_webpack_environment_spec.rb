require 'rails_helper'
require 'sprockets'
require 'webpack_rails/sprockets_environment'

RSpec.describe WebpackRails::SprocketsEnvironment do
  def root_dir
    Rails.root
  end

  def bundles_dir
    root_dir.join('tmp/webpack/bundles')
  end

  let(:webpack_task_config) { nil }
  let(:env) do
    new_env = Sprockets::Environment.new
    WebpackRails::SprocketsEnvironment.enhance!(new_env, webpack_task_config)
    new_env.append_path root_dir.join('app/assets/javascripts')
    new_env.append_path bundles_dir
    new_env
  end
  let(:asset) { env["application.js"] }

  before(:each) do
    # ensure daemon not running
    WebpackRails::Task.release if WebpackRails::Task.alive?
  end

  context "with dev server" do
    let(:webpack_task_config) do
      {
        dev_server: true,
        host: 'localhost',
        port: 9001,
      }
    end

    before(:each) do
      asset # build asset
    end

    it "builds the asset with a reference to the bundle" do
      expect(asset).not_to be_nil
      expect(asset.to_s).to include(%{document.write('<script src="http://localhost:9001/posts.bundle.js"></script>');})
    end
  end

  context "without dev server" do
    let(:webpack_task_config) do
      {
        dev_server: false,
      }
    end

    before(:all) do
      # remove any existing webpack build artifacts
      Dir["#{bundles_dir}/*.js"].each{ |p| File.delete(p) }

      # run webpack like assets:precompile
      `bundle exec rake webpack:build_once`
    end

    before(:each) do
      asset # build asset
    end

    it "builds the asset with bundle included" do
      expect(asset).not_to be_nil
      expect(asset.to_s).to include('PostsScreen')
    end

    it "does not start the dev server" do
      expect(WebpackRails::Task.alive?).to be false
    end
  end
end
