require 'rails_helper'
require 'sprockets/webpack_environment'
require 'webpack_rails'
require 'webpack_rails/sprockets_integration'


RSpec.describe WebpackRails::Task do
  after(:each) do
    WebpackRails::Task.release
  end

  it "spawns a node server" do
    server = WebpackRails::Task.server
  end

  it "runs webpack" do
    result = WebpackRails::Task.run_webpack
    expect(result).not_to be_nil
  end
end


RSpec.describe "webpack bundle in prod" do
  before(:each) do
    root = File.expand_path('../../', __FILE__)

    @env = Sprockets::Environment.new
    @env = Sprockets::WebpackEnvironment.copy_from(@env)
    @env.append_path File.join(root, 'app/assets/javascripts')
    @env.append_path File.join(root, 'tmp/webpack/bundles')

    @env.webpack_config = {
      dev_server: false,
    }

    WebpackRails::SprocketsIntegration.install(@env, @env.webpack_config)

    # run webpack as in assets:precompile
    system "bundle exec rake webpack:build_once"

    # ensure daemon not running
    WebpackRails::Task.release
  end

  it "builds successfully" do
    asset = @env["application.js"]
    expect(asset).not_to be_nil
    expect(asset.to_s).to include('PostsScreen')

    # check daemon wasn't launched
    controller = WebpackRails::Task.instance_variable_get(:@controller)
    pid = nil
    found_process = false
    if controller
      begin
        pid = controller.pid
      rescue Errno::ENOENT
      end
    end
    if pid
      begin
        Process.getpgid(controller.pid)
        found_process = true
      rescue Errno::ESRCH
      end
    end

    expect(found_process).to be false
  end
end

