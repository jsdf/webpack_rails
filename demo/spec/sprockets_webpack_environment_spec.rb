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
  let(:asset) { env["posts.bundle.js"] }
  let(:webpack_environment_vars) do
    {
      'WEBPACK_TEST_DEFINE' => 'WEBPACK_RAILS_1234567890',
    }
  end

  before(:each) do
    # ensure daemon not running
    WebpackRails::Task.release if WebpackRails::Task.alive?
  end

  context "with watch" do
    let(:webpack_task_config) do
      {
        watch: true,
        env: webpack_environment_vars,
      }
    end

    before(:each) do
      # remove any existing webpack build artifacts
      Dir["#{bundles_dir}/*.js"].each{ |p| File.delete(p) }
    end

    before(:each) { asset }

    it "processes the asset to include bundle contents" do
      expect(asset).not_to be_nil
      expect(asset.to_s).to include('PostsScreen')
    end

    it "passes through config env vars" do
      expect(asset.to_s).to include(webpack_environment_vars['WEBPACK_TEST_DEFINE'])
    end

    it "starts the watch daemon" do
      expect(WebpackRails::Task.alive?).to be true
    end
  end

  context "without dev server or watch" do
    let(:webpack_task_config) do
      {
        dev_server: false,
        watch: false,
        # env at build time comes from application.rb
      }
    end

    before(:all) do
      # run webpack like assets:precompile
      # uses config from application.rb
      `WEBPACK_TEST_DEFINE="default" WEBPACK_TEST_DEFINE_OVERWRITE="WEBPACK_RAILS_1234567890" bundle exec rake webpack:build_once`
    end

    before(:each) { asset }

    it "processes the asset to include bundle contents" do
      expect(asset).not_to be_nil
      expect(asset.to_s).to include('PostsScreen')
    end

    it "passes through config env vars" do
      expect(asset.to_s).to include(webpack_environment_vars['WEBPACK_TEST_DEFINE'])
    end

    it "does not start the dev server" do
      expect(WebpackRails::Task.alive?).to be false
    end
  end
end
